terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
      configuration_aliases = [aws.environment]
    }
  }

  required_version = ">= 0.14.9"
}

#------------------------------------------------------------------

data "aws_subnet" "selected" {
  provider = aws.environment
  id       = var.subnet_id
}

data "template_file" "userdata" {
  template  = "${file("${path.module}/userdata/standalone.tpl")}"
  vars      = {
    mode            = var.mode
    instance_dns    = var.instance_dns
    volume_mount_id = var.volume_mount_id
  }
}

#------------------------------------------------------------------

resource "aws_ebs_volume" "example" {
  provider = aws.environment

  availability_zone = data.aws_subnet.selected.availability_zone
  snapshot_id       = var.snapshot_id

  tags = {
    Name            = var.volume_name
    Environment     = var.environment
  }
}

resource "aws_security_group" "allow_tls" {
  provider           = aws.environment
  
  vpc_id             = data.aws_subnet.selected.vpc_id

  dynamic ingress {
    for_each           = var.inbound
    content {
      description      = ingress.key
      from_port        = ingress.value.from
      to_port          = ingress.value.to
      protocol         = ingress.value.protocol
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]  
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sec-grp-${var.instance_name}"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  provider           = aws.environment

  name               = "generic-inst-pro-${var.instance_name}"
  role               = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  provider           = aws.environment

  name               = "generic-role-${var.instance_name}"
  path               = "/"
  assume_role_policy = "${file("${path.module}/trust.json")}"
  managed_policy_arns = [aws_iam_policy.policy_one.arn]
}

resource "aws_iam_policy" "policy_one" {
  provider           = aws.environment

  name               = var.policy_name
  policy             = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["route53:*", "s3:Put*", "s3:Delete*", "ses:SendRawEmail",]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

locals {
  default_tags = {
    Name            = var.instance_name
    DNSName         = var.instance_dns
    Environment     = var.environment
  }
  merged_tags  = merge(local.default_tags, var.tags)
}

resource "aws_instance" "app_server" {
  provider                = aws.environment

  ami                     = var.image_id
  instance_type           = var.instance_size
  key_name                = var.key_name
  user_data               = data.template_file.userdata.rendered
  availability_zone       = data.aws_subnet.selected.availability_zone
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [aws_security_group.allow_tls.id]
  iam_instance_profile    = aws_iam_instance_profile.test_profile.name

  lifecycle { 
    ignore_changes = [] 
  }

  tags = local.merged_tags
}

resource "aws_volume_attachment" "ebs_att" {
  provider    = aws.environment

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.app_server.id
}

data "aws_route53_zone" "dns_zone" {
  provider      = aws.environment
  name          = var.route53_dns_tld
  private_zone  = false
}

resource "aws_route53_record" "playground" {
  provider      = aws.environment

  zone_id       = data.aws_route53_zone.dns_zone.zone_id
  name          = var.instance_dns
  type          = "A"
  ttl           = "300"
  records       = [aws_instance.app_server.public_ip]
}
