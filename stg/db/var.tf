variable "db_uname" {
  description = "Database User Name"
}

variable "db_password" {
  description = "Database Password"
}

variable "db_storage" {
  description = "Storage size of the Database in GB"
}

variable "db_instance_type" {
  description = "Instance type of the Database"

  default = "db.t2.micro"
}

variable "db_name" {
  description = "Database Name"

  default = "upr1_db"
}