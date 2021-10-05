# Lecture 2:


resource "aws_iam_role" "s3_consumer_lambda_iam_role" {
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

resource "aws_iam_role_policy_attachment" "s3_consumer_lambda_basic_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.s3_consumer_lambda_iam_role.name
}

data "archive_file" "s3_consumer_lambda_zip" {
  type        = "zip"
  source_dir  = var.s3_consumer_lambda_function_code_path
  output_path = "${var.s3_consumer_lambda_function_code_path}/lambda.zip"
}

resource "aws_lambda_function" "s3_consumer_lambda" {
  filename      = "${var.s3_consumer_lambda_function_code_path}/lambda.zip"
  function_name = "my_lambda"
  role          = aws_iam_role.s3_consumer_lambda_iam_role.arn
  handler       = "my_lambda.lambda_handler"

  source_code_hash = data.archive_file.s3_consumer_lambda_zip.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      DB_NAME        = var.dynamodb_table_name
      S3_BUCKET_NAME = var.s3_bucket_name
    }
  }
}

resource "aws_lambda_permission" "s3_invoke_lambda_permission" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_consumer_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.my_first_bucket.arn
}

resource "aws_s3_bucket_notification" "file_uploaded_notification" {
  bucket = aws_s3_bucket.my_first_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_consumer_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_invoke_lambda_permission]
}

