resource "aws_db_subnet_group" "gtd_db_subnetgroup" {
    depends_on = [
      aws_subnet.db_subnets
    ]
  name       = "gtd_db_subnetgroup"
  subnet_ids = [aws_subnet.db_subnets.*.id]

  tags = {
    Name = "gtd_db_subnetgroup"
  }
}

resource "aws_db_instance" "gtd_posgres_db" {
    depends_on = [
      aws_db_subnet_group.gtd_db_subnetgroup
    ]
  db_name                = "app"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.5"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username               = "postgres"
  password               = random_password.db_password.result
  ### we can enable MultiAZ to incrase the availability of the database
  ### database encryption can be enabled to secure the data at rest

}

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
            environmental_variables=[
                {
                    "name": "VTT_DBPASSWORD"
                    "value":"${random_password.db_password.result}" 
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

resource "null_resource" "db_init" {
    depends_on = [
      aws_db_instance.gtd_posgres_db,aws_ecs_task_definition.gtd_postgres_db_init_td
    ]
    provisioner "local-exec" {
        command = "aws ecs run-task --task-definition ${aws_ecs_task_definition.gtd_postgres_db_init_td.arn} --region ${var.region} --network-configuration {awsvpcConfiguration= {subnets=[${aws_subnet.db_subnets.*.id}]}}"    
    }
}