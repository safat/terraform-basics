provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_db_instance" "upr1-db" {
  engine = "mysql"
  allocated_storage = "${var.db_storage}"
  instance_class = "${var.db_instance_type}"
  name = "${var.db_name}"
  username = "${var.db_uname}"
  password = "${var.db_password}"
}
