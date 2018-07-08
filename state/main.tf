provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "tf-upr-state" {
  bucket = "tf-upr-state"
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    name = "S3 Remote Terraform State Store"
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 2
  write_capacity = 2

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    name = "DynamoDB Terraform State Lock Table"
  }
}
