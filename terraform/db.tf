resource "aws_db_subnet_group" "gtd_db_subnetgroup" {
  name       = "gtd_db_subnetgroup"
  subnet_ids = [aws_subnet.db_subnets.*.id]

  tags = {
    Name = "gtd_db_subnetgroup"
  }
}

resource "aws_db_instance" "gtd_posgres_db" {
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