locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = local.common_tags
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-app-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.app_security_group_id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    apt-get update -y
    apt-get install -y nginx curl unzip

    systemctl enable nginx
    systemctl start nginx

    INSTANCE_ID=$(curl -sS \
      -X PUT \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
      http://169.254.169.254/latest/api/token)

    TOKEN="$INSTANCE_ID"

    INSTANCE_ID=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)

    AVAILABILITY_ZONE=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/placement/availability-zone)

    cat > /var/www/html/index.html <<HTML
    <html>
      <head>
        <title>Cloud-Lab-04</title>
      </head>
      <body>
        <h1>Cloud-Lab-04 Auto Scaling Application</h1>
        <p>Instance ID: $INSTANCE_ID</p>
        <p>Availability Zone: $AVAILABILITY_ZONE</p>
      </body>
    </html>
    HTML

    systemctl restart nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-${var.environment}-app"
      Tier = "application"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-${var.environment}-app-volume"
    })
  }

  update_default_version = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-launch-template"
  })
}
