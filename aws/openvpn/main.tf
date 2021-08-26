
# Provider platform defenition

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# Resources to be created in Provider platform

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
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.20.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private1-subnet"
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
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route.id
}


resource "aws_security_group" "allow_RDP_in" {
  name        = "allow-RDP-in-sg"
  description = "Allow RDP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "RDP from VPC"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ping icmp protocol"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}


resource "aws_security_group" "allow_openvpn_in" {
  name        = "openvpn-in-sg"
  description = "OpenVPN security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 945
    to_port     = 945
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}








resource "aws_instance" "JumpServer" {
  ami                         = "ami-0685cb76db3624f25"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_RDP_in.id]
  key_name                    = "Virginia_Key"
  /* Use your own key name */
  count = 1

  tags = {
    Name = "JumpServer ${count.index}"
  }

}

variable "server_username" {
  description = "Admin Username to access server"
  type        = string
  default     = "openvpn"
  /* Use your own default name */
}

variable "server_password" {
  description = "Admin Password to access server"
  type        = string
  default     = "password"
  /* Use your own default password */
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.openvpn.id
  allocation_id = aws_eip.lbip.id
}

resource "aws_instance" "openvpn" {
  ami                    = "ami-037ff6453f0855c46"
  instance_type          = "t2.micro"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_openvpn_in.id]
  key_name                    = "your_Key"
  /* Use your own key name */
  user_data = <<-EOF
              admin_user=${var.server_username}
              admin_pw=${var.server_password}
              EOF
  tags = {
    Name = "OpenVPNServer"
  }
}


resource "aws_eip" "lbip" {
  vpc = true

  tags = {
    Name = "lbip-OpenVPN"
  }
  
}


output "JumpServer_addresses" {
  value = ["${aws_instance.JumpServer.*.public_dns}"]
  description = "The public url address of the JumpServer"
}


output "public_ip" {
  description = "Contains the public IP address for OpenVPN"
  value       = aws_eip.lbip.public_ip
}
