variable "env" {
  description = "Name of the Environment"
}

variable "server_port" {
  description = "The port that server binds to"
  default = 8080
}

variable "instance_type" {
  description = "Type of the instance"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
}

variable "key_name" {
  description = "Name of the SSH Key",
  default = "cli-southeast-2"
}
