data "aws_availability_zones" "available" {
  state = "available"
}

locals {

  azs = slice(data.aws_availability_zones.available.names, 0 , 2)

  cidr_blocks_public = ["10.0.0.0/24", "10.0.1.0/24"]
  cidr_blocks_private = ["10.0.10.0/24", "10.0.11.0/24"]
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  enable_dns_hostnames = true
  enable_dns_support =  true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id = aws_vpc.main.id 
  cidr_block = local.cidr_blocks_public[count.index]
  availability_zone = local.azs[count.index]

  map_public_ip_on_launch = true

  tags = {
    Tier = "public"
    Name = "${local.name_prefix}-public-${local.azs[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count = length(local.azs)

  vpc_id = aws_vpc.main.id 
  cidr_block = local.cidr_blocks_private[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Tier = "private"
    Name = "${local.name_prefix}-private-${local.azs[count.index]}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id 

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public"{
  count = length(aws_subnet.public)

  subnet_id = aws_subnet.public[count.index].id 
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id 

  tags = {
    Name = "${local.name_prefix}-private-rt"
  }
}

resource "aws_route_table_association" "private"{
  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id 
  route_table_id = aws_route_table.private.id
}