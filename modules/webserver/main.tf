provider aws {
  region = "ap-southeast-1"
}

resource "aws_launch_configuration" "upr-launch-config-1" {
  image_id = "ami-81cefcfd"
  instance_type = "${var.instance_type}"
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