terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

### Network Setup ###
resource "aws_vpc" "adlab_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
   Name = "adlab_vpc"
  }
 }
 
resource "aws_internet_gateway" "adlab_igw" {
  vpc_id = aws_vpc.adlab_vpc.id

   tags = {
     Name = "adlab_igw"
   }
}

resource "aws_subnet" "adlab_sn" {
  vpc_id =  aws_vpc.adlab_vpc.id
  cidr_block = var.adlab_sn
  map_public_ip_on_launch = "true"
  availability_zone = var.aws_az

  tags = {
    Name = "adlab_sn"
  }
}

resource "aws_default_route_table" "adlab_route_table" {
  default_route_table_id = aws_vpc.adlab_vpc.default_route_table_id
 
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.adlab_igw.id
    }
  tags = {
      Name = "adlab_route_table"
    }
}

# General SG for Now
resource "aws_security_group" "web_sg" {
  name = "web_sg"
  vpc_id =  aws_vpc.adlab_vpc.id
  
  # RDP access from current IP
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  # Interconnectivity within subnet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.adlab_win_sn
  }

  # Access to Linux via Instance Connect
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.instance_connect_ips
  }

  # Direct access to Jenkins instances
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## EC2 Instance Setup ##

resource "aws_network_interface" "adlab_dc01_nic" {
  subnet_id   = aws_subnet.adlab_sn.id
  private_ips = ["10.10.10.10"]
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "primary_network_interface"
  }
}

# Domain Controller
resource "aws_instance" "adlab_dc01" {
  ami           = data.aws_ami.win2019.id
  instance_type = "t2.micro"
  key_name      = var.key_pair
  
  network_interface {
    network_interface_id = aws_network_interface.adlab_dc01_nic.id
    device_index         = 0
  }

  user_data     = "${file("userdata/dc01")}"

  tags = {
    Name = "adlab_dc01"
  }
}

# Domain Member Server
resource "aws_instance" "adlab_gen01" {
  ami           = data.aws_ami.win2019.id
  instance_type = "t2.micro"
  subnet_id   = aws_subnet.adlab_sn.id
  key_name      = var.key_pair
  security_groups = [aws_security_group.web_sg.id]

  user_data     = "${file("userdata/gen01")}"

  tags = {
    Name = "adlab_gen01"
  }
}

# Domain Member Server
resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.awsLinux.id
  instance_type = "t2.micro"
  subnet_id   = aws_subnet.adlab_sn.id
  key_name      = var.key_pair
  security_groups = [aws_security_group.web_sg.id]

  user_data     = "${file("userdata/jenkins")}"

  tags = {
    Name = "jenkins"
  }
}