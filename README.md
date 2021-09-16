# IaC AWS Terraform Workshop
This repo contains code used for a workshop about IaC using Terraform.

## prerequisite
- Terraform:
  - https://www.terraform.io/downloads.html
  - You should be able to run: `terraform -help`
- AWS CLI:
  - [Download the CLI for your OS](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
  - You should be able to run: `aws --version`
- Install some form of terraform extension for your idea. This makes it easier to find any syntax errors.
  - VS Code: https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform
  - IntelliJ plugin: https://plugins.jetbrains.com/plugin/7808-terraform-and-hcl


### Lecture 1
In this lecture you should configure the AWS CLI, initiate terraform and deploy an S3 Bucket.

1. Configure aws: 
   1. Run `aws configure` 
   2. Type in your personal IAM credentials. 
   3. When asked about default region type: `eu-central-1` and set default output format to `json`.
2. Clone this repository
3. Open the code in your editor of choice.
4. Set S3 bucket name: Open the [variables.tf](variables.tf) file and change the `s3_bucket_name` value from `<YOUR_BUCKET_NAME>`, to whatever you want to call your S3 bucket.
5. Initiate Terraform: Open your terminal in the project folder and run `terraform init`.
6. Preview what will happen if you deploy this code: `terraform plan`.
7. Deploy your S3 bucket: `terraform apply` (when asked if you want to apply this code, type `yes` and hit enter).
8. Login to the AWS Console and find your S3 bucket. Try uploading any text file to this bucket.


### Lecture 2
In this lecture we will create a lambda function that will run every time a file is uploaded to our S3 bucket.

1. Uncomment the code in [lecture_2.tf](lecture_2.tf).
2. Open the the [variables.tf](variables.tf) file and make sure the `s3_consumer_lambda_function_code_path` variable is pointing to the folder containing the python code for lecture 2. The path should be as follows: `./lambda_code/lecture_2`.
3. Preview the changes: `terraform plan`
4. Deploy changes: `terraform apply`
5. Upload a new file to the S3 bucket.
6. View logs:
   1. Open the Lambda function in the AWS Console. 
   2. Click on monitoring and view the Lambda Function logs in CloudWatch. 
   3. Open the CloudWatch log stream, and you should see that our application has run and printed the upload event from S3.


### Lecture 3
In this lecture we will create a DynamoDB table and update our lambda function to consume files uploaded to S3 and store the content in the DynamoDB table.
> The Lambda function will only support json lists, so use the file provided [here](lambda_code/birds.json) when uploading to the S3 bucket.

1. Uncomment the code in [lecture_3.tf](lecture_3.tf).
2. Set DynamoDB table name: Open the [variables.tf](variables.tf) file and change the `dynamodb_table_name` value from `<YOUR_TABLE_NAME>`, to whatever you want to call your DynamoDB table.
3. Preview the changes: `terraform plan`
4. Deploy changes: `terraform apply`
5. Upload the [json file](lambda_code/birds.json) to your S3 bucket.
6. Open the DynamoDB table in the AWS Console. The content of the file should now be stored in the DynamoDB table.


### Lecture 4
...

## Cleanup
1. Empty S3 bucket using the AWS Console
2. Run `terraform destory`
