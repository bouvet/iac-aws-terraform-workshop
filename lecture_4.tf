# Lecture 4:


#######################################################################
# Lambda function resources #
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

resource "aws_iam_policy" "db_reader_lambda_additional_policies" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Scan"
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
  role       = aws_iam_role.db_reader_lambda_iam_role.name
}

data "archive_file" "db_reader_lambda_zip" {
  type        = "zip"
  source_dir  = "./lambda_code/lecture_4"
  output_path = "./lambda_code/lecture_4/lambda.zip"
}

resource "aws_lambda_function" "db_reader_lambda" {
  filename      = "./lambda_code/lecture_4/lambda.zip"
  function_name = "db_reader"
  role          = aws_iam_role.db_reader_lambda_iam_role.arn
  handler       = "db_reader.lambda_handler"

  source_code_hash = data.archive_file.db_reader_lambda_zip.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      DB_NAME = var.dynamodb_table_name
    }
  }
}


#######################################################################
# API Gateway #
resource "aws_api_gateway_rest_api" "birds_api" {
  name = "birds_api"
}

# creating the '/birds' resource
resource "aws_api_gateway_resource" "birds_resource" {
  parent_id   = aws_api_gateway_rest_api.birds_api.root_resource_id
  path_part   = "birds"
  rest_api_id = aws_api_gateway_rest_api.birds_api.id
}

# creating the '/{id}' resource and attaches it to the '/birds' resource
resource "aws_api_gateway_resource" "bird_resource" {
  parent_id   = aws_api_gateway_resource.birds_resource.id
  path_part   = "{id}"
  rest_api_id = aws_api_gateway_rest_api.birds_api.id
}

# creating a GET method on the '/{id)' resource
resource "aws_api_gateway_method" "bird_resource_get_method" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.bird_resource.id
  rest_api_id   = aws_api_gateway_rest_api.birds_api.id
  request_parameters = {
    "method.request.path.id" = true
  }
}

# integrating a lambda function on the GET method
resource "aws_api_gateway_integration" "lambda_integration_db_reader" {
  http_method             = aws_api_gateway_method.bird_resource_get_method.http_method
  resource_id             = aws_api_gateway_resource.bird_resource.id
  rest_api_id             = aws_api_gateway_rest_api.birds_api.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.db_reader_lambda.invoke_arn
}

# grants the API Gateway access to invoke the db_reader lambda function.
resource "aws_lambda_permission" "api_gateway_invoke_db_reader_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.db_reader_lambda.function_name
  principal     = "apigateway.amazonaws.com"

# Uncomment the three lines bellow. I had to do some special line commenting to ensure the source_arn variable would not not escape the block comment.

  source_arn = "${aws_api_gateway_rest_api.birds_api.execution_arn}/*/*/*"

}

# creating a deployment of our API Gateway
resource "aws_api_gateway_deployment" "demo_env" {
  depends_on  = [aws_api_gateway_integration.lambda_integration_db_reader, aws_lambda_function.db_reader_lambda]
  rest_api_id = aws_api_gateway_rest_api.birds_api.id
  stage_name  = "demo"

  # Added timestamp to enforce new deployment of the api gateway.
  description = "Deployed at ${timestamp()}"
}

# outputs the deployment URL
output "api_stage_endpoint" {
  value = aws_api_gateway_deployment.demo_env.invoke_url
}


