resource "aws_vpc" "main_vpc" {       # Create main VPC
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "public" {       # Create public subnets
  count = length(var.public_subnets)
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-${count.index+1}" }
}

resource "aws_subnet" "private" {      # Create private subnets
  count = length(var.private_subnets)
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  tags = { Name = "private-subnet-${count.index+1}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = { Name = "main-igw" }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id
  tags = { Name = "main-nat-gw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "public_asso" {
  count = length(var.public_subnets)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_asso" {
  count = length(var.private_subnets)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
