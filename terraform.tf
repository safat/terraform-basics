terraform {
  backend "s3" {
    encrypt = true
    bucket = "tf-upr-state"
    dynamodb_table = "terraform-state-lock-dynamo"
    region = "ap-southeast-1"
    key = "terraform.tfstate"
  }
}
