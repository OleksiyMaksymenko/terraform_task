terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "state-terraform-my-task"
    key    = "state"
    region = "eu-west-3"
  }
}

provider "aws" {
    region= "eu-west-3"
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc_b.id
}

resource "aws_security_group_rule" "ssh" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg.id
  to_port           = 0
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "out_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_ecr_repository" "postrge_sql" {
  name                 = "container_postgresql"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "node_js" {
  name                 = "container_node"
  image_tag_mutability = "MUTABLE"
}
