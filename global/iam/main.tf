provider "aws" {
  region = "ap-southeast-1"
}

data "aws_iam_policy_document" "ec2_read_only" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*"]
    resources = [
      "*"]
  }
}

resource "aws_iam_policy" "ec2_read_only" {
  name = "ec2-read-only"
  policy = "${data.aws_iam_policy_document.ec2_read_only.json}"
}

resource "aws_iam_policy_attachment" "ec2_access" {
  count = "${length(var.user_names)}"
  name = "${element(aws_iam_user.example.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.ec2_read_only.arn}"
}

resource "aws_iam_user" "example" {
  count = "${length(var.user_names)}"
  name = "${element(var.user_names, count.index)}"
}