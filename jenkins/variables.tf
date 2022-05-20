# Set to "My IP" for Services like RDP / SSH
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

variable "instance_connect_ips" {
  description = "AWS instance connect IPs (US)"
  type        = list(string)
  default     = ["18.206.107.24/29", "3.16.146.0/29", "13.52.6.112/29", "18.237.140.160/29"]
}

# Instances
# Get latest Windows Server 2019 AMI
data "aws_ami" "win2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }
}

# Get latest Amazon Linux AMI
data "aws_ami" "awsLinux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs*"]
  } 
}


# Empty variables for injecting variables into module

# Root file VPC
variable "root_vpc" {

}

# Root file default subnet
variable "root_sn" {

}

# Root file default subnet CIDR
variable "root_sn_cidr" {

}

# IAM profile for retrieving secrets
variable "iam_profile" {

}