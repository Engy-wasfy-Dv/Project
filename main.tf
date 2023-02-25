provider "aws" {
region = "us-west-2"
}

variable "vpc-cidr-block" {
}

variable "subnet-cidr-block1" {

}
resource "aws_vpc" "Shs-vpc" {
    cidr_block = var.vpc-cidr-block
    tags = {
        Name = "Shs VPC"
    }
}

resource "aws_subnet" "public-subnet-shs" {
  vpc_id     = aws_vpc.shs-vpc.id
  cidr_block = var.subnet-cidr-block1

  tags = {
    Name = "Public shs sub"
  }
}

resource "aws_internet_gateway" "inter-gw" {
  vpc_id = aws_vpc.shs-vpc.id

  tags = {
    Name = "Internet Gateway Shs"
  }
}
resource "aws_route_table_association" "rt-shs" {
  subnet_id      = aws_subnet.public-subnet-shs.id
  route_table_id = aws_route_table.shs-route-table.id
}

resource "aws_route_table" "shs-route-table" {
  vpc_id = aws_vpc.cairo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inter-gw.id
  }

  tags = {u
    Name = "public Shs Route Table"
  }
}


resource "aws_instance" "shs-web" {
  ami = "ami-0ceecbb0f30a902a6"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id      = aws_subnet.public-subnet-shs.id
  count = 4
  vpc_security_group_ids = [aws_security_group.shs_tls.id]
  key_name = "vockey"
  
  tags = {
    Name = "public shs instance"
  }

}


resource "aws_security_group" "shs_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.shs-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

