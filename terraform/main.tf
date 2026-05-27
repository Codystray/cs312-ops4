
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "minecraft" {
  name        = "ops4-minecraft-sg"
  description = "SSH and Minecraft access for the Ops 4 k3s host"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH (administrative access, restricted to a known source)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ops4-minecraft-sg"
  }
}

# Persistent resources, managed outside Terraform (created via AWS CLI in Ops 3).
# Read as data sources so terraform destroy never removes the image or backups.
data "aws_ecr_repository" "minecraft" {
  name = "ops3-minecraft-server"
}

data "aws_s3_bucket" "backups" {
  bucket = var.backup_bucket
}

# Ubuntu 24.04 LTS AMI. Owner 099720109477 is Canonical.
# Same dynamic lookup as the Ops 3 Terraform; known-good.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "minecraft" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.minecraft.id]
  iam_instance_profile   = "LabInstanceProfile"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "ops4-minecraft"
  }
}
