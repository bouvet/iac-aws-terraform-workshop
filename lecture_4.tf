# Lecture 4:
# Create an API Gateway, create a lambda function that can query the DynamoDB table for objects, and connect the function to the API Gateway.


resource "aws_iam_role" "db_reader_lambda_iam_role" {
  name = "db_reader_lambda_iam_role"

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

resource "aws_iam_role_policy_attachment" "db_reader_lambda_basic_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.db_reader_lambda_iam_role.name
}

data "archive_file" "db_reader_lambda_zip" {
  type = "zip"
  source_dir = "./lambda_code/lecture_4"
  output_path = "./lambda_code/lecture_4/lambda.zip"
}

resource "aws_lambda_function" "db_reader_lambda" {
  filename = "./lambda_code/lecture_4/lambda.zip"
  function_name = "my_get_bird"
  role = aws_iam_role.db_reader_lambda_iam_role.arn
  handler = "my_get_bird.lambda_handler"

  source_code_hash = data.archive_file.db_reader_lambda_zip.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      DB_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_iam_policy" "db_reader_lambda_additional_policies" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.my_dynamodb_table.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
  policy_arn = aws_iam_policy.db_reader_lambda_additional_policies.arn
  role = aws_iam_role.db_reader_lambda_iam_role.name
}

# API Gateway
resource "aws_api_gateway_rest_api" "birds_api" {
  name = "birds_api"
}

resource "aws_api_gateway_resource" "birds_resource" {
  parent_id = aws_api_gateway_rest_api.birds_api.root_resource_id
  path_part = "{id}"
  rest_api_id = aws_api_gateway_rest_api.birds_api.id
}

resource "aws_api_gateway_method" "get_request" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = aws_api_gateway_resource.birds_resource.id
  rest_api_id = aws_api_gateway_rest_api.birds_api.id
  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "lambda_integration" {
  http_method = aws_api_gateway_method.get_request.http_method
  resource_id = aws_api_gateway_resource.birds_resource.id
  rest_api_id = aws_api_gateway_rest_api.birds_api.id
  type = "AWS_PROXY"
  integration_http_method = "GET"
  uri = aws_lambda_function.db_reader_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "demo_env" {

  rest_api_id = aws_api_gateway_rest_api.birds_api.id
  stage_name = "demo"
}

resource "aws_lambda_permission" "api_gateway_invoke_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.db_reader_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.birds_api.execution_arn}/*/*"
}

output "api_endpoint" {
  value = aws_api_gateway_deployment.demo_env.invoke_url
}
