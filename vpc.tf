terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "Terraform-user"
}



resource "aws_vpc" "VPC01" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true
   tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "IGW01" {
  vpc_id = aws_vpc.VPC01.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet01" {
  vpc_id     = aws_vpc.VPC01.id
  cidr_block = "192.168.0.0/18"

  tags = {
    Name = "Public-subnet01"
  }
}

resource "aws_subnet" "public_subnet02" {
  vpc_id     = aws_vpc.VPC01.id
  cidr_block = "192.168.64.0/18"

  tags = {
    Name = "Public-subnet02"
  }
}



resource "aws_subnet" "private_subnet01" {
  vpc_id     = aws_vpc.VPC01.id
  cidr_block = "192.168.128.0/18"

  tags = {
    Name = "Private-subnet01"
  }
}



resource "aws_subnet" "private_subnet02" {
  vpc_id     = aws_vpc.VPC01.id
  cidr_block = "192.168.192.0/18"

  tags = {
    Name = "Private-subnet02"
  }
}

#creation of route table

resource "aws_route_table" "Public-RT01" {
  vpc_id = aws_vpc.VPC01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW01.id
  }

  
  tags = {
    Name = "Public-RT01"
  }
}


resource "aws_route_table" "Public-RT02" {
  vpc_id = aws_vpc.VPC01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW01.id
  }

  
  tags = {
    Name = "Public-RT02"
  }
}
resource "aws_route_table_association" "Public01-to-publicrt01" {
  subnet_id      = aws_subnet.public_subnet01.id
  route_table_id = aws_route_table.Public-RT01.id
}

resource "aws_route_table_association" "Public02-to-publicrt02" {
  subnet_id      = aws_subnet.public_subnet02.id
  route_table_id = aws_route_table.Public-RT02.id
}

resource "aws_eip" "EIP-for-NAT"{
   vpc = true
   tags = {
      name = "EIP01"
   }
}

resource "aws_nat_gateway" "NAT01" {
  allocation_id = aws_eip.EIP-for-NAT.id
  subnet_id  = aws_subnet.public_subnet01.id

  tags = {
    Name = "NAT01"
  }
}
  
resource "aws_route_table" "Private-RT01" {
  vpc_id = aws_vpc.VPC01.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT01.id
  }

  
  tags = {
    Name = "Private-RT01"
  }
}


resource "aws_route_table" "Private-RT02" {
  vpc_id = aws_vpc.VPC01.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT01.id
  }

  
  tags = {
    Name = "Private-RT02"
  }
}

resource "aws_route_table_association" "Private01-to-privatet01" {
  subnet_id      = aws_subnet.private_subnet01.id
  route_table_id = aws_route_table.Private-RT01.id
}

resource "aws_route_table_association" "Private02-to-privatet02" {
  subnet_id      = aws_subnet.private_subnet02.id
  route_table_id = aws_route_table.Private-RT02.id
}



