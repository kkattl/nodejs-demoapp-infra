# Security Group (EC2) 

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Allow traffic from ALB to port 3000"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "from ALB"
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
    Env  = var.environment
  }
}


# IAM Role

resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-${var.environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}


# Launch Template for nodes 

data "aws_ami" "amzn2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = data.aws_ami.amzn2.id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(file("../../user_data/user_data.sh"))

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    security_groups       = [aws_security_group.ec2.id]
    delete_on_termination = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-node"
      Env  = var.environment
    }
  }
}


# Auto Scaling Group

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.3.1"

  name = "${var.project_name}-${var.environment}-asg"

  create_launch_template = false
  launch_template_id      = aws_launch_template.app.id
  launch_template_version = "$Latest"

  vpc_zone_identifier = module.vpc.private_subnets

  min_size         = var.min_capacity
  max_size         = var.max_capacity
  desired_capacity = var.desired_capacity

  target_group_arns = [aws_lb_target_group.app.arn]

    scaling_policies = {
    requests = {
      policy_type = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ALBRequestCountPerTarget"
          resource_label = "${aws_lb.public.arn_suffix}/${aws_lb_target_group.app.arn_suffix}"
        }
        target_value = 100
      }
    }
  }
}
