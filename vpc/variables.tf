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
variable "adlab_sn_pr1" {
  description = "adlab Subnet CIDR"
  type        = string
  default     = "10.10.10.0/24"
}

# Set Subnet CIDR for creation
variable "adlab_sn_pr2" {
  description = "adlab Subnet CIDR"
  type        = string
  default     = "10.10.11.0/24"
}

# Set Subnet CIDR for creation
variable "adlab_sn_pub1" {
  description = "adlab Subnet CIDR"
  type        = string
  default     = "10.10.20.0/24"
}

# Set Subnet CIDR for creation
variable "adlab_sn_pub2" {
  description = "adlab Subnet CIDR"
  type        = string
  default     = "10.10.21.0/24"
}

# Set Subnet CIDR for SG
variable "adlab_win_sn" {
  description = "adlab Subnet CIDR"
  type        = list(string)
  default     = ["10.10.10.0/24", "10.10.11.0/24", "10.10.20.0/24", "10.10.21.0/24"]
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
