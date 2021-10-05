# Lecture 1:

resource "aws_s3_bucket" "my_first_bucket" {
  # To reference values in terraform variables you can use the 'var' keyword followed by dot (.) and the variable name.
  # Update the 'bucket' parameter bellow to point to the s3_bucket_name variable.
  bucket = var.s3_bucket_name
}
