# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}

# vpc 
resource "aws_vpc" "success" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "success"
  }
}

# private subnet
resource "aws_subnet" "success-priv-subnet" {
  vpc_id     = aws_vpc.success.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "success-priv-subnet"
  }
}

# public subnet 
resource "aws_subnet" "success-pub-subnet" {
  vpc_id     = aws_vpc.success.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "success-pub-subnet"
  }
}

# Public route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.success.id

  tags = {
    Name = "public-route-table"
  }
}

# private route table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.success.id

   tags = {
    Name = "private-route-table"
  }
}

# public route table association
resource "aws_route_table_association" "public-rout-asso" {
  subnet_id      = aws_subnet.success-pub-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

# private route table association
resource "aws_route_table_association" "private-rout-asso" {
  subnet_id      = aws_subnet.success-priv-subnet.id
  route_table_id = aws_route_table.private-route-table.id
}

# success igw
resource "aws_internet_gateway" "success-igw" {
  vpc_id = aws_vpc.success.id

  tags = {
    Name = "success-igw"
  }
}

# success igw route
resource "aws_route" "success-igw-route" {
  route_table_id            = aws_route_table.public-route-table.id
  gateway_id                = aws_internet_gateway.success-igw.id
  destination_cidr_block    = "0.0.0.0/0"
  
  
 }

# eip
resource "aws_eip" "success-eip" {
    vpc                     = true
    associate_with_private_ip = "10.0.0.4"
    depends_on                = [aws_internet_gateway.success-igw]
}

# ngw association with public Subnet
resource "aws_nat_gateway" "success-ngw" {
  allocation_id = aws_eip.success-eip.id
  subnet_id     = aws_subnet.success-pub-subnet.id
  
  tags = {
    Name = "success-ngw"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.success-eip]
}

# ngw route
resource "aws_route" "success-ngw-route" {
  route_table_id            = aws_route_table.private-route-table.id
  nat_gateway_id            = aws_nat_gateway.success-ngw.id
  destination_cidr_block    = "0.0.0.0/0"
}