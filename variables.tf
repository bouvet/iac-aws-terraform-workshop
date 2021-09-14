variable "s3_bucket_name" {
  description = "A globally unique name for your S3 bucket"
  default = "endres-test-10001"
}

variable "dynamodb_table_name" {
  description = "Just some random name for your table"
  default = "awesome_table_1"
}

variable "lambda_function_code_path" {
  description = "Local path to the lambda function code"
  default = "./lambda_code_lecture_3"
}