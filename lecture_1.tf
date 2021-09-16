# Lecture 1:
# Create an S3 bucket using terraform and upload a file to that bucket in the AWS Console.

resource "aws_s3_bucket" "my_first_bucket" {
  bucket = var.s3_bucket_name
}
