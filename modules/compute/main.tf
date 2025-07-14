  resource "aws_security_group" "alb_sg" {
    name   = var.alb_sg_name
    vpc_id = var.vpc_id

    dynamic "ingress" {
      for_each = var.alb_ingress_rules == null ? [] : var.alb_ingress_rules
      content {
        description = ingress.value.description
        from_port   = ingress.value.from_port
        to_port     = ingress.value.to_port
        protocol    = ingress.value.protocol
        cidr_blocks = ingress.value.cidr_blocks
      }
    }

    dynamic "egress" {
      for_each = var.alb_egress_rules == null ? [] : var.alb_egress_rules
      content {
        description = egress.value.description
        from_port   = egress.value.from_port
        to_port     = egress.value.to_port
        protocol    = egress.value.protocol
        cidr_blocks = egress.value.cidr_blocks
      }
    }
  }

  resource "aws_security_group" "ec2_sg" {
    name   = var.ec2_sg_name
    vpc_id = var.vpc_id

    dynamic "ingress" {
      for_each = var.ec2_ingress_rules == null ? [] : var.ec2_ingress_rules
      content {
        description     = ingress.value.description
        from_port       = ingress.value.from_port
        to_port         = ingress.value.to_port
        protocol        = ingress.value.protocol
        security_groups = [aws_security_group.alb_sg.id] # Allow access from ALB security group
        }
    }

    dynamic "egress" {
      for_each = var.ec2_egress_rules == null ? [] : var.ec2_egress_rules
      content {
        #description = egress.value.description
        from_port   = egress.value.from_port
        to_port     = egress.value.to_port
        protocol    = egress.value.protocol
        cidr_blocks = egress.value.cidr_blocks
      }
    }
  }

  # Separate security group rules to avoid circular dependency

  # resource "aws_security_group_rule" "alb_to_ec2" {
  #   type                     = "egress"
  #   from_port                = 80
  #   to_port                  = 80
  #   protocol                 = "tcp"
  #   source_security_group_id = aws_security_group.ec2_sg.id
  #   security_group_id        = aws_security_group.alb_sg.id
  # }

  # resource "aws_security_group_rule" "ec2_from_alb" {
  #   type                     = "ingress"
  #   from_port                = 80
  #   to_port                  = 80
  #   protocol                 = "tcp"
  #   source_security_group_id = aws_security_group.alb_sg.id
  #   security_group_id        = aws_security_group.ec2_sg.id
  # }

  # Application Load Balancer (ALB) and Target Group

  resource "aws_lb" "app_alb" {
    name               = "app-alb"
    internal           = false
    load_balancer_type = "application"
    subnets            = var.public_subnets
    security_groups    = [aws_security_group.alb_sg.id]

    depends_on = [var.vpc_id, aws_security_group.alb_sg]
  }

  resource "aws_lb_target_group" "app_tg" {
    name        = "app-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "instance"

    health_check {
      enabled             = true
      healthy_threshold   = 2
      interval            = 30
      matcher             = "200"
      path                = "/"
      port                = "traffic-port"
      protocol            = "HTTP"
      timeout             = 5
      unhealthy_threshold = 2
    }
  }

  #Listener for ALB

  resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.app_alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app_tg.arn

    }
  }

  module "autoscaling" {
    source  = "terraform-aws-modules/autoscaling/aws"
    version = "9.0.1"

    name                          = var.asg_name
    vpc_zone_identifier           = var.private_subnets
    min_size                      = var.asg_min
    max_size                      = var.asg_max
    desired_capacity              = var.asg_desired
    health_check_type             = "ELB"
    health_check_grace_period     = 300


    create_launch_template = true
    launch_template_name   = "launch-tmpl"

    image_id        = var.image_id
    instance_type   = var.instance_type
    key_name        = var.key_name
    security_groups = [aws_security_group.ec2_sg.id]

 user_data = base64encode(<<-EOT
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get install -y apache2

  sudo mkdir -p /var/www/html
  echo "<h1>Welcome to Apache on Ubuntu (ASG)</h1>" | sudo tee /var/www/html/index.html > /dev/null

  sudo systemctl enable apache2
  sudo systemctl start apache2
EOT
)

    depends_on = [aws_lb_target_group.app_tg]
  }


  # Add this resource to create a target group attachment for the Auto Scaling group

  resource "aws_autoscaling_attachment" "asg_attachment" {
    autoscaling_group_name = module.autoscaling.autoscaling_group_name
    lb_target_group_arn   = aws_lb_target_group.app_tg.arn

  depends_on = [module.autoscaling]

  }



  #sacle high CPU utilization alarm

  resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
    alarm_name          = "cpu_utilization_high"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 60
    statistic           = "Average"
    threshold           = 70
    alarm_description   = "This metric monitors CPU utilization"
    alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
    

    dimensions = {
      AutoScalingGroupName = module.autoscaling.autoscaling_group_name
    }

  }

  resource "aws_autoscaling_policy" "scale_out" {
    name                   = "${var.asg_name}-scale-out"
    scaling_adjustment     = 1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    autoscaling_group_name = module.autoscaling.autoscaling_group_name
  }

  #sacle low CPU utilization alarm

  resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
    alarm_name          = "cpu_utilization_low"
    comparison_operator = "LessThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 60
    statistic           = "Average"
    threshold           = 30
    alarm_description   = "This metric monitors CPU utilization"
    alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

    dimensions = {
      AutoScalingGroupName = module.autoscaling.autoscaling_group_name
    }

  }

  resource "aws_autoscaling_policy" "scale_in" {
    name                   = "${var.asg_name}-scale-in"
    scaling_adjustment     = -1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    autoscaling_group_name = module.autoscaling.autoscaling_group_name
  }
