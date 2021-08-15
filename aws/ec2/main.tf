/* Terraform template for creating AWS ec2 instance with open ssh access */

provider "aws" {

  region = "us-east-1"
  profile ="default" 

}

resource "aws_security_group" "firstsg" {
 name = "first_security_gp" 
 ingress {  
  description = "SSH Port"   
  protocol  = "tcp"   
  from_port = 22    
  to_port   = 22   
  cidr_blocks = ["0.0.0.0/0"]
 }  
 
egress { 
   from_port   = 0  
   to_port     = 0  
   protocol    = "-1"   
   cidr_blocks = ["0.0.0.0/0"]
  } 
  tags = { 
    Name = "Security Group"
   }
}

resource "aws_instance" "tf_ec2_ex" {
  ami          = "ami-062f7200baf2fa504"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.firstsg.name}"]
  key_name = "Virginia_Key" /* Use your own key name */
  count = 5

  tags = {
    name = "HelloWorld!, Terraform EC2"
  }
}



