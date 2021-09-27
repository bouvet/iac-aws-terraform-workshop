variable "s3_bucket_name" {
  description = "A globally unique name for your S3 bucket"
  default = "<YOUR_BUCKET_NAME>"
}

variable "dynamodb_table_name" {
  description = "Just some random name for your table"
  default = "<YOUR_TABLE_NAME>"
}

variable "s3_consumer_lambda_function_code_path" {
  description = "Local path to the lambda function code"
  default = "../lambda_code/lecture_2"
}