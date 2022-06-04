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

# VPC / Networking
module "vpc" {
  source        = "./vpc"

  aws_az = var.aws_az
}

# Domain Controller
resource "aws_instance" "adlab_dc01" {
  depends_on = [module.vpc]
  ami           = data.aws_ami.win2019.id
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.adlab_secrets_profile.name}"
  #key_name      = var.key_pair
  
  network_interface {
    network_interface_id = module.vpc.dc01_nic_id
    device_index         = 0
  }

  user_data     = "${file("userdata/dc01")}"

  tags = {
    Name = "adlab_dc01"
  }
}

# Domain Member Server
resource "aws_instance" "adlab_gen01" {
  depends_on = [module.vpc]
  ami           = data.aws_ami.win2019.id
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.adlab_secrets_profile.name}"
  subnet_id   = module.vpc.pub1_id
  #key_name      = var.key_pair
  vpc_security_group_ids = [module.vpc.default_sg_id]
  
  user_data     = "${file("userdata/gen01")}"

  tags = {
    Name = "adlab_gen01"
  }
}


# Jenkins Environment

module "jenkins" {
  source        = "./jenkins"

  root_vpc      = module.vpc.adlab_vpc
  root_sn       = module.vpc.pr2
  root_sn_cidr  = module.vpc.sn_pr2
  iam_profile   = aws_iam_instance_profile.adlab_secrets_profile.name

}
