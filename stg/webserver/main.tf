provider "aws" {
  region = "ap-southeast-1"
}

module "webserver" {
  source = "../../modules/webserver"

  env = "stg"
  instance_type = "t2.micro"
  cluster_name = "upr-web"
  db_remote_state_bucket = "tf-upr-state"
  db_remote_state_key = "stg-db-terraform.tfstate"
  enable_autoscaling = "false"
}
