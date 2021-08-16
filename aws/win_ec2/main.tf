provider "aws" {
  region  = "us-east-1"
  profile = "default"
}


resource "aws_vpc" "main" {

  cidr_block                       = "10.10.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  assign_generated_ipv6_cidr_block = false

  tags = {
    name = "main"
  }

}


resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.10.0/24"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.20.0/24"
  availability_zone = "us-east-1a"
tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "gateway" {
       vpc_id = aws_vpc.main.id
tags = {
    Name = "vpc-gateway"
  }
}

resource "aws_route_table" "route" {
      vpc_id = aws_vpc.main.id
           route {
              cidr_block = "0.0.0.0/0"
              gateway_id = aws_internet_gateway.gateway.id
          }
tags = {
                 Name = "gatewayroute"
          }
       }
resource "aws_route_table_association" "public"{
   subnet_id   = aws_subnet.public.id
   route_table_id = aws_route_table.route.id
}


resource "aws_security_group" "allow_rdp" {
  name        = "allow_rdp"
  description = "Allow rdp traffic"
  vpc_id      = aws_vpc.main.id

  ingress {

    from_port = 3389 #  By default, the windows server listens on TCP port 3389 for RDP
    to_port   = 3389
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}


resource "aws_instance" "example" {
  ami                         = "ami-0685cb76db3624f25"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_rdp.id]
  key_name                    = "Virginia_Key"
  /* Use your own key name */
  count = 1

}