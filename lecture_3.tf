# Lecture 3:


resource "aws_dynamodb_table" "my_dynamodb_table" {
  name = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_policy" "s3_consumer_lambda_additional_policies" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.my_dynamodb_table.arn}"
    },
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.my_first_bucket.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dynamodb_and_s3_policy_attachment" {
  policy_arn = aws_iam_policy.s3_consumer_lambda_additional_policies.arn
  role = aws_iam_role.s3_consumer_lambda_iam_role.name
}
