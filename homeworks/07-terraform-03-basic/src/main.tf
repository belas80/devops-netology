provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.web_instance_type_map[terraform.workspace]
  count         = var.web_instance_count_map[terraform.workspace]

  key_name = "deployer-key"

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_instance" "app_server2" {
  for_each      = var.instances
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.web_instance_type_map[terraform.workspace]

  key_name = "deployer-key"

  tags = {
    Name = each.key
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = sensitive(file("~/.ssh/id_rsa.pub"))
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}