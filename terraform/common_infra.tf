### Create New VPC
resource "aws_vpc" "gtd_vpc" {
  cidr_block = var.vpc_cidr
  tags ={
        Name = "gtd_vpc"
    }
}

#### Create Public Subnet
resource "aws_subnet" "public_subnets" {
  count                     = length(var.public_subnets_cidr)
  vpc_id                    = aws_vpc.gtd_vpc.id
  cidr_block                = element(var.public_subnets_cidr,count.index)
  availability_zone         = element(data.aws_availability_zones.available.names,count.index)
  map_public_ip_on_launch   = true
  tags                      = {
    Name = "Public_Subnet-${count.index+1}"
  }
}


#### Create Web Subnet
resource "aws_subnet" "web_subnets" {
  count                    = length(var.web_subnets_cidr)
  vpc_id                   = aws_vpc.gtd_vpc.id
  cidr_block               = element(var.web_subnets_cidr,count.index)
  availability_zone        = element(data.aws_availability_zones.available.names,count.index)
  map_public_ip_on_launch  = false
  tags                     = {
    Name = "Web_Subnet-${count.index+1}"
  }
}


#### Create DB Subnet
resource "aws_subnet" "db_subnets" {
  count                    = length(var.db_subnets_cidr)
  vpc_id                   = aws_vpc.gtd_vpc.id
  cidr_block               = element(var.db_subnets_cidr,count.index)
  availability_zone        = element(data.aws_availability_zones.available.names,count.index)
  map_public_ip_on_launch  = false
  tags                     = {
    Name = "DB_Subnet-${count.index+1}"
  }
}

#### Create Internet Gateway
resource "aws_internet_gateway" "gtd_igw" {
  vpc_id = aws_vpc.gtd_vpc.id
  tags = {
    Name = "gtd_igw"
  }
}

##### Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.gtd_vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gtd_igw.id
  }
  tags = {
    Name = "Public_RouteTable"
  }
}

##### Create Public Route table associations
resource "aws_route_table_association" "public_subnet_associate" {
  count = length(var.public_subnets_cidr)
  subnet_id = element(aws_subnet.public_subnets.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}


##### Creat NAT GATEWAY Public IPs
resource "aws_eip" "nat_gw_eips" {
  count = length(var.public_subnets_cidr)
  vpc = true
}
##### Create NAT Gateway
resource "aws_nat_gateway" "gtd_vpc_nat_gw" {
  count         = length(var.public_subnets_cidr)
  allocation_id = element(aws_eip.nat_gw_eips.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
  depends_on    = [aws_internet_gateway.gtd_igw]
}
 

##### Create Internet Route Table
resource "aws_route_table" "internet_rt" {
  count  = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.gtd_vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gtd_vpc_nat_gw.*.id,count.index)
  }
  tags = {
    Name = "Internet_RouteTable-${count.index+1}"
  }
}

##### Create Internet Route table association to web and DB subnets
resource "aws_route_table_association" "web_subnet_associate" {
  count = length(var.web_subnets_cidr)
  subnet_id = element(aws_subnet.web_subnets.*.id,count.index)
  route_table_id = element(aws_route_table.internet_rt.*.id,count.index)
}

resource "aws_route_table_association" "db_subnet_associate" {
  count = length(var.db_subnets_cidr)
  subnet_id = element(aws_subnet.db_subnets.*.id,count.index)
  route_table_id = element(aws_route_table.internet_rt.*.id,count.index)
}