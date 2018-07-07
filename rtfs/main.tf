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
}
