provider aws {
  region = "ap-southeast-1"
}

resource "aws_launch_configuration" "upr-launch-config-1" {
  image_id = "ami-81cefcfd"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = [
    "${aws_security_group.upr1-example-sg.id}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "upr1-example-sg" {
  name = "${var.env}-${var.cluster_name}-instance-sg"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "upr1-autoscaling-group" {
  launch_configuration = "${aws_launch_configuration.upr-launch-config-1.id}"
  availability_zones = [
    "${data.aws_availability_zones.all.names}"]
  load_balancers = [
    "${aws_elb.upr1-elb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "name"
    value = "${var.env}-${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}

resource "aws_elb" "upr1-elb" {
  name = "${var.env}-${var.cluster_name}-elb"
  availability_zones = [
    "${data.aws_availability_zones.all.names}"]
  security_groups = [
    "${aws_security_group.upr1-elb-sg.id}"]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "upr1-elb-sg" {
  name = "${var.env}-${var.cluster_name}-elb-sg"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = "${var.enable_autoscaling == true ? 1 : 0}"

  scheduled_action_name = "scale_out_during_business_hours"
  min_size = 2
  max_size = 10
  desired_capacity = 3
  recurrence = "0 9 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.upr1-autoscaling-group.name}"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = "${var.enable_autoscaling == true ? 1 : 0}"

  scheduled_action_name = "scale_in_at_night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.upr1-autoscaling-group.name}"
}

resource "aws_cloudwatch_metric_alarm" "hight_cpu_utilization" {
  alarm_name = "${var.env}-${var.cluster_name}_high_cpu_utilization"
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.upr1-autoscaling-group.name}"
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 5
  period = 60
  statistic = "Average"
  threshold = 90
  unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count = "${format("%.1s", var.instance_type) == "t" ? 1 : 0}"

  alarm_name = "${var.env}-${var.cluster_name}_low_cpu_credit_balance"
  namespace = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.upr1-autoscaling-group.name}"
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods = 5
  period = 60
  statistic = "Minimum"
  threshold = 10
  unit = "Count"
}

data "aws_availability_zones" "all" {
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "${var.db_remote_state_bucket}"
    key = "${var.db_remote_state_key}"
    region = "ap-southeast-1"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/script/server.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address = "${data.terraform_remote_state.db.db_address}"
  }
}
