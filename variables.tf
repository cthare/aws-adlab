# General Setup
# Set Key Pair - uncomment this section to set key pair if needed
#variable "key_pair" {
#  description = "Key Pair Name"
#  type        = string
#  default     = "win-lab"
#}

variable "aws_profile" {
  description = "AWS Profile"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "aws_az" {
  description = "AWS AZ"
  type        = string
  default     = "us-west-2a"
}

## Networking
# Set VPC CIDR
variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.10.0.0/16"
}

# Set Subnet CIDR for creation
variable "adlab_sn" {
  description = "adlab Subnet CIDR"
  type        = string
  default     = "10.10.10.0/24"
}

# Set Subnet CIDR for SG
variable "adlab_win_sn" {
  description = "adlab Subnet CIDR"
  type        = list(string)
  default     = ["10.10.10.0/24"]
}

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