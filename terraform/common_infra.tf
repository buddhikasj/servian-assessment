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
  vpc_id                    = aws_vpc.gtd-vpc.id
  cidr_block                = element(var.public_subnets_cidr,count.index)
  availability_zone         = element(var.azs,count.index)
  map_public_ip_on_launch   = true
  tags                      = {
    Name = "Public_Subnet-${count.index+1}"
  }
}


#### Create Web Subnet
resource "aws_subnet" "web_subnets" {
  count                    = length(var.web_subnets_cidr)
  vpc_id                   = aws_vpc.gtd-vpc.id
  cidr_block               = element(var.web_subnets_cidr,count.index)
  availability_zone        = element(var.azs,count.index)
  map_public_ip_on_launch  = true
  ####### Ideally we can make this subnet a private one, but that would reqire us to set up Elastic IPs and NAT gateways per AZ to download the container image/ or wecan copy the image to ECR and setup a VPC enpoint. 
  ####### Currently keeping the web subnet public to minimise depenencies
  tags                     = {
    Name = "Web_Subnet-${count.index+1}"
  }
}


#### Create DB Subnet
resource "aws_subnet" "db_subnets" {
  count                    = length(var.db_subnets_cidr)
  vpc_id                   = aws_vpc.gtd-vpc.id
  cidr_block               = element(var.db_subnets_cidr,count.index)
  availability_zone        = element(var.azs,count.index)
  map_public_ip_on_launch  = false
  tags                     = {
    Name = "DB_Subnet-${count.index+1}"
  }
}

#### Create Internet Gateway
resource "aws_internet_gateway" "gtd_igw" {
  vpc_id = aws_vpc.gtd-vpc.id
  tags = {
    Name = "gtd_igw"
  }
}

##### Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.gtd_vpc
  route = [ {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gtd_igw.id

  } ]
  tags = {
    Name = "Public_RouteTable"
  }
}

##### Create Route table associations
resource "aws_route_table_association" "public_subnet_associate" {
  count = length(var.public_subnets_cidr)
  subnet_id = element(aws_subnet.public_subnets.id,count.indix)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "web_subnet_associate" {
  count = length(var.web_subnets_cidr)
  subnet_id = element(aws_subnet.web_subnets.id,count.indix)
  route_table_id = aws_route_table.public_rt.id
}
