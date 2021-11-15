provider "aws" {
  region = "eu-central-1"
}

data "aws_caller_identity" "current" {}

data "aws_ami" "main" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["suse-sles-15-sp3-byos-*-hvm-ssd-x86_64"]
  }
}

resource "aws_security_group" "main" {
  name        = "ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.main.id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = "tmuntaner"
}

resource "aws_iam_user" "main" {
  name = "experiment-user"
}

resource "aws_iam_user_policy" "main" {
  name = "test"
  user = aws_iam_user.main.id

  policy = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "main" {
  statement {
    actions   = ["ec2:Describe*"]
    effect    = "Allow"
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = [aws_vpc_endpoint.ec2.id]
      variable = "aws:SourceVpce"
    }
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.eu-central-1.ec2"
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [var.subnet_id]
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "vpc-endpoint"
  description = "Allow HTTPS inbound traffic for vpc endpoint"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }
}
