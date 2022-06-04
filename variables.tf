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