

resource "aws_security_group" "jenkins_sg" {
  name = "jenkins_sg"
  vpc_id =  var.root_vpc.id
  
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
    cidr_blocks = var.root_sn_cidr
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

# Jenkins Windows node
resource "aws_instance" "jenkins_windows" {
  ami           = data.aws_ami.win2019.id
  instance_type = "t2.micro"
  iam_instance_profile = var.iam_profile
  subnet_id   = var.root_sn.id
  security_groups = [aws_security_group.jenkins_sg.id]

  user_data     = "${file("${path.module}/userdata/jenkins_windows")}"
  

  tags = {
    Name = "jenkins_windows"
  }
}

# Jenkins instance main
resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.awsLinux.id
  instance_type = "t2.micro"
  subnet_id   = var.root_sn.id
  security_groups = [aws_security_group.jenkins_sg.id]

  user_data     = "${file("${path.module}/userdata/jenkins")}"

  tags = {
    Name = "jenkins"
  }
}