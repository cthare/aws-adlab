### Prereqs ###
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

### IAM ###

# Roles and policies to access secrets
resource "aws_iam_role" "ec2_secrets_access_role" {
  name               = "ec2_secrets_access"
  assume_role_policy = "${file("iampolicies/ec2AssumeRole.json")}"
}

resource "aws_iam_policy" "adlab_secrets" {
  name        = "adlab_secrets"
  description = "Access to secrets"
  policy      = "${file("iampolicies/readSecrets.json")}"
}

resource "aws_iam_policy_attachment" "ec2_adlab_attachment" {
  name       = "ec2_adlab_attachment"
  roles      = ["${aws_iam_role.ec2_secrets_access_role.name}"]
  policy_arn = "${aws_iam_policy.adlab_secrets.arn}"
}

resource "aws_iam_instance_profile" "adlab_secrets_profile" {
  name  = "adlab_secrets_profile"
  role = "${aws_iam_role.ec2_secrets_access_role.name}"
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

# Build subnets
resource "aws_subnet" "adlab_sn_pr1" {
  vpc_id =  aws_vpc.adlab_vpc.id
  cidr_block = var.adlab_sn_pr1
  map_public_ip_on_launch = "false"
  availability_zone = var.aws_az

  tags = {
    Name = "adlab_sn_pr1"
  }
}

resource "aws_subnet" "adlab_sn_pr2" {
  vpc_id =  aws_vpc.adlab_vpc.id
  cidr_block = var.adlab_sn_pr2
  map_public_ip_on_launch = "false"
  availability_zone = var.aws_az

  tags = {
    Name = "adlab_sn_pr2"
  }
}

resource "aws_subnet" "adlab_sn_pub1" {
  vpc_id =  aws_vpc.adlab_vpc.id
  cidr_block = var.adlab_sn_pub1
  map_public_ip_on_launch = "true"
  availability_zone = var.aws_az

  tags = {
    Name = "adlab_sn_pub1"
  }
}

resource "aws_subnet" "adlab_sn_pub2" {
  vpc_id =  aws_vpc.adlab_vpc.id
  cidr_block = var.adlab_sn_pub2
  map_public_ip_on_launch = "true"
  availability_zone = var.aws_az

  tags = {
    Name = "adlab_sn_pub2"
  }
}

# Elastic IPs for Nat Gateways
resource "aws_eip" "adlab_ngw_eip_pr1" {
  depends_on = [aws_internet_gateway.adlab_igw]
  vpc = true
}

resource "aws_eip" "adlab_ngw_eip_pr2" {
  depends_on = [aws_internet_gateway.adlab_igw]
  vpc = true
}

# Nat Gateways
resource "aws_nat_gateway" "adlab_ngw_pr1" {
  allocation_id = aws_eip.adlab_ngw_eip_pr1.id
  subnet_id     = aws_subnet.adlab_sn_pub1.id

  tags = {
    Name = "adlab_ngw_pr1"
  }

  depends_on = [aws_internet_gateway.adlab_igw]
}

resource "aws_nat_gateway" "adlab_ngw_pr2" {
  allocation_id = aws_eip.adlab_ngw_eip_pr2.id
  subnet_id     = aws_subnet.adlab_sn_pub2.id

  tags = {
    Name = "adlab_ngw_pr2"
  }

  depends_on = [aws_internet_gateway.adlab_igw]
}

# Default route table to IGW
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

# Private route table 1
resource "aws_route_table" "adlab_rt_pr1" {
  depends_on = [aws_nat_gateway.adlab_ngw_pr2]
  vpc_id =  aws_vpc.adlab_vpc.id
 
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.adlab_ngw_pr1.id
    }
  tags = {
      Name = "adlab_rt_pr1"
    }
}

# Private route table 2
resource "aws_route_table" "adlab_rt_pr2" {
  depends_on = [aws_nat_gateway.adlab_ngw_pr2]
  vpc_id =  aws_vpc.adlab_vpc.id
 
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.adlab_ngw_pr2.id
    }
  tags = {
      Name = "adlab_rt_pr2"
    }
}

# Route table associations
resource "aws_route_table_association" "adlab_rt_pr1_assc" {
  depends_on = [aws_route_table.adlab_rt_pr1]
  subnet_id      = aws_subnet.adlab_sn_pr1.id
  route_table_id = aws_route_table.adlab_rt_pr1.id
}

resource "aws_route_table_association" "adlab_rt_pr2_assc" {
  depends_on = [aws_route_table.adlab_rt_pr2]
  subnet_id      = aws_subnet.adlab_sn_pr2.id
  route_table_id = aws_route_table.adlab_rt_pr2.id
}

# General SG for now
resource "aws_security_group" "adlab_default_sg" {
  name = "adlab_default_sg"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## EC2 Instance Setup ##

resource "aws_network_interface" "adlab_dc01_nic" {
  subnet_id   = aws_subnet.adlab_sn_pr1.id
  private_ips = ["10.10.10.10"]
  security_groups = [aws_security_group.adlab_default_sg.id]

  tags = {
    Name = "primary_network_interface"
  }
}

# Domain Controller
resource "aws_instance" "adlab_dc01" {
  ami           = data.aws_ami.win2019.id
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.adlab_secrets_profile.name}"
  #key_name      = var.key_pair
  
  
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
  iam_instance_profile = "${aws_iam_instance_profile.adlab_secrets_profile.name}"
  subnet_id   = aws_subnet.adlab_sn_pub1.id
  #key_name      = var.key_pair
  security_groups = [aws_security_group.adlab_default_sg.id]

  user_data     = "${file("userdata/gen01")}"

  tags = {
    Name = "adlab_gen01"
  }
}

/*
# Jenkins Environment
module "jenkins" {
  source        = "./jenkins"

  root_vpc      = aws_vpc.adlab_vpc
  root_sn       = aws_subnet.adlab_sn_pr2
  root_sn_cidr  = var.adlab_win_sn
  iam_profile   = aws_iam_instance_profile.adlab_secrets_profile.name

}
*/