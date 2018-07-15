provider "aws" {
  region = "ap-southeast-1"
}

module "db" {
  source = "../../modules/db"

  db_password = "223346622"
  db_uname = "root"
  db_instance_type = "db.t2.micro"
  db_name = "demodb"
  db_storage = "30"
  env = "stg"
}