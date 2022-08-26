#### Create DB subnet group to manage to placement of DB
resource "aws_db_subnet_group" "gtd_db_subnetgroup" {
    depends_on = [
      aws_subnet.db_subnets
    ]
  name       = "gtd_db_subnetgroup"
  subnet_ids = "${aws_subnet.db_subnets.*.id}"

  tags = {
    Name = "gtd_db_subnetgroup"
  }
}

#### Create the db instance
resource "aws_db_instance" "gtd_posgres_db" {
    depends_on = [
      aws_db_subnet_group.gtd_db_subnetgroup
    ]
  identifier             = "gts-postgres-db"
  db_name                = "app"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12.11"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username               = "postgres"
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.gtd_db_subnetgroup.id
  skip_final_snapshot    = true
  ### we can enable MultiAZ to incrase the availability of the database
  ### database encryption can be enabled to secure the data at rest

}

###### To initialize the DB I have used an ECS task which runs one time via the provisioner block in a null resource
###### ECS task basically downloads the same servian container image and runs "updatedb -s"

###### Create ECS task definition
resource "aws_ecs_task_definition" "gtd_postgres_db_init_td" {
    depends_on = [
      aws_db_instance.gtd_posgres_db
    ]
  family                   = "gtd_postgres_db_init"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode(local.db_init_container_definition)
}

###### Create container definition to be used in ECS task definition
locals {
    db_init_container_definition = [
        {
            name      = "gtd-postgres-db-init"
            image     = "${var.web_container_image}"
            cpu       = 1024
            memory    = 2048
            essential = true
            portMappings = [
                {
                containerPort = 3000
                hostPort      = 3000
                }
            ]
            environment=[
                {
                    "name": "VTT_DBPASSWORD"
                    "value":"${random_password.db_password.result}"
                    #### This will show the db password in the ECS task definition, we can use AWS secrets manager or parameter store to the passwrod and refer it as a secret in container definition 
                    #### To keep the dependencies to a minimum I am just passing the value here  as an environmental variable but it is critically important for a production app 
                },
                {
                    "name": "VTT_DBHOST"
                    "value":"${aws_db_instance.gtd_posgres_db.address}"            
                }
            ]
            command     = ["updatedb", "-s"]
      }
    ]
}


###### Create null resource to execute the AWS cli command to execute the above create ECS task to initialize the DB
###### This section creates the dependency for AWS cli to be installed on the computer running the terraform command
###### And the AWS Cli profile being used is the same one as in AWS provider block
resource "null_resource" "db_init" {
    depends_on = [
      aws_db_instance.gtd_posgres_db,aws_ecs_task_definition.gtd_postgres_db_init_td
    ]
    provisioner "local-exec" {
        command = "aws ecs run-task --cluster ${aws_ecs_cluster.gtd_web_cluster.arn} --task-definition ${aws_ecs_task_definition.gtd_postgres_db_init_td.arn} --launch-type=\"FARGATE\" --network-configuration \"awsvpcConfiguration={subnets=[${aws_subnet.web_subnets.0.id},${aws_subnet.web_subnets.1.id}], assignPublicIp='DISABLED'}\"  --region ${var.region}  --profile ${var.aws_profile}"    
        
    }
    triggers = { run="1"}
}