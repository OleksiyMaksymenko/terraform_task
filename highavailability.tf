resource "aws_lb_target_group" "target_group_b" { 
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_b.id
}

resource "aws_lb" "load_balancer_b" {
  internal = false

  security_groups = [
    aws_security_group.sg.id
  ]

  subnets = [
    aws_subnet.b_private_a.id,
    aws_subnet.b_private_b.id
  ]

  ip_address_type = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.load_balancer_b.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group_b.arn
  }
}

resource "aws_placement_group" "test" {
  name     = "test"
  strategy = "spread"
}

resource "aws_autoscaling_group" "example" {

  capacity_rebalance  = true
  desired_capacity    = 2
  max_size            = 5
  min_size            = 2

  vpc_zone_identifier = [
    aws_subnet.b_private_a.id, 
    aws_subnet.b_private_b.id
  ]
  placement_group = aws_placement_group.test.id
  health_check_type = "ELB"
  launch_configuration = aws_launch_configuration.as_conf.name
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "as_conf" {
  key_name = "key-pair-my"
  name          = "web_config"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.sg.id]
}