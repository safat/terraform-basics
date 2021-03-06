output "db_address" {
  value = "${aws_db_instance.upr1-db.address}"
}

output "db_port" {
  value = "${aws_db_instance.upr1-db.port}"
}

output "sample_output" {
  value = "${aws_db_instance.upr1-db.allocated_storage}"
}