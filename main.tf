# Lecture 1:
# Create an S3 bucket using terraform and upload a file to that bucket in the AWS Console.

resource "aws_s3_bucket" "my_first_bucket" {
  bucket = var.s3_bucket_name
}


# Lecture 2:
# Make use of module and create a lambda function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir = var.lambda_function_code_path
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "my_lambda" {
  filename      = "${path.module}/lambda.zip"
  function_name = "my_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "my_lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      DB_NAME = var.dynamodb_table_name
      S3_BUCKET_NAME = var.s3_bucket_name
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.my_first_bucket.arn
}

resource "aws_s3_bucket_notification" "file_uploaded_notification" {
  bucket = aws_s3_bucket.my_first_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# Lecture 3:
# Create a DynamoDB table and use lambda function to write data from file uploaded to S3 into the DynamoDB table.
/*
resource "aws_dynamodb_table" "my_dynamodb_table" {
  name = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_policy" "my_lambda_additional_policies" {
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

resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
  policy_arn = aws_iam_policy.my_lambda_additional_policies.arn
  role = aws_iam_role.iam_for_lambda.name
}
*/

# Lecture 4:
# Create an API Gateway, create a lambda function that can query the DynamoDB table for objects, and connect the function to the API Gateway.
