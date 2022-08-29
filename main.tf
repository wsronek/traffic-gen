terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket" "traffic-gen-bucket" {
  bucket = "traffic-gen"
  tags = {
    Name = "Traffic generator python locust script"
  }
}

resource "aws_s3_object" "traffic-gen-object" {
  key    = "traffic-gen"
  bucket = aws_s3_bucket.traffic-gen-bucket.id
  source = "${path.module}/traffic-gen.py"
}

resource "aws_security_group" "allow-ssh" {
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-c10d36bb"

  ingress {
    description      = "SSH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "Allow SSH"
  }
}

resource "aws_iam_role" "traffic-gen-iam-role" {
  name = "traffic-gen-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "traffic-gen-iam-role-policy" {
  name = "traffic-gen-iam-role-policy"
  role = "${aws_iam_role.traffic-gen-iam-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "traffic-gen-iam-instance-profile" {
  name = "traffic-gen-iam-instance-profile"
  role = "${aws_iam_role.traffic-gen-iam-role.name}"
}

data "local_file" "urls" {
  filename = "${path.module}/urls"
}

resource "aws_instance" "traffic-gen-instance" {
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = "t2.micro"
  count                  = 2
  vpc_security_group_ids = [ aws_security_group.allow-ssh.id ]
  iam_instance_profile   = "${aws_iam_instance_profile.traffic-gen-iam-instance-profile.name}"
  subnet_id              = "subnet-e02dc286"
  key_name               = "sol-eng-us-e"
  user_data              = templatefile("${path.module}/traffic-gen-init.sh", {
    traffic-gen-script-s3-bucket = aws_s3_bucket.traffic-gen-bucket.id
    traffic-gen-urls             = data.local_file.urls.content
  })
  tags = {
    Name = "${var.prefix}-${count.index}"
  }
}

output "instances" {
  value       = "${aws_instance.traffic-gen-instance.*.public_ip}"
  description = "Public IP address details"
}