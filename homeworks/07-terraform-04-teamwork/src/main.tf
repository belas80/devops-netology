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

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = var.my-instances
  name     = "my-instance-${each.key}"

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.web_instance_type_map[terraform.workspace]
  key_name      = "deployer-key"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = sensitive(file("~/.ssh/id_rsa.pub"))
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}