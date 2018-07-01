provider aws {
    region = "ap-southeast-1"

}

resource "aws_instance" "upr-1" {
    ami = "ami-81cefcfd"
    instance_type = "t2.micro"

     tags {
        Name = "upr-1-example"
    }
}
