data "aws_ami" "amazon-linux-2-kernel-5" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }
}

resource "aws_iam_instance_profile" "burining-role-profile" {
#   name = aws_iam_role.burining-role.name
  role = aws_iam_role.burining-role.name
}

resource "aws_launch_template" "burining-web-template" {
  name = "burining-lt-${var.enviroment}-web-open2"

  image_id = data.aws_ami.amazon-linux-2-kernel-5.id
  instance_type = "${var.instance_types}"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type = "gp3"
      volume_size = 8
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.burining-role-profile.arn
  }

  vpc_security_group_ids = [aws_security_group.burining-ec2sg.id]

  user_data = filebase64("./ec2_user_data.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "burining-ec2-${var.enviroment}-web-open2"
    }
  }
}

resource "aws_autoscaling_group" "burining-asg" {
  name = "burining-asg"
  max_size = 4
  min_size = 1
  desired_capacity = 1
  vpc_zone_identifier = [ for sub in aws_subnet.burining-web-pri-sub: sub.id ]
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true

  launch_template {
    id = aws_launch_template.burining-web-template.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [
      load_balancers, target_group_arns
    ]
  }
}

resource "aws_autoscaling_policy" "burining-asg-policy" {
  autoscaling_group_name = aws_autoscaling_group.burining-asg.name
  name = "burining-asg-policy"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

resource "aws_autoscaling_attachment" "burining-asg-attach" {
  autoscaling_group_name = aws_autoscaling_group.burining-asg.id
  lb_target_group_arn = aws_lb_target_group.burining-tg.arn
  # elb = aws_lb.burining-alb.id
}