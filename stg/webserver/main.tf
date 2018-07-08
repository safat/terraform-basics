provider aws {
  region = "ap-southeast-1"
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "tf-upr-state"
    key = "db.stg.terraform.tfstate"
    region = "ap-southeast-1"
  }
}

resource "aws_launch_configuration" "upr-launch-config-1" {
  image_id = "ami-81cefcfd"
  instance_type = "t2.micro"
  security_groups = [
    "${aws_security_group.upr1-example-sg.id}"]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello World" > index.html
                echo "${data.terraform_remote_state.db.db_address}" >> index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "upr1-example-sg" {
  name = "terraform_example_instance"

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
    key = "Name"
    value = "upr1-autoscaling-group"
    propagate_at_launch = true
  }
}

resource "aws_elb" "upr1-elb" {
  name = "upr1-elb"
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
  name = "upr1-elb-sg"

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