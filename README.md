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
  - VS Code Marketplace Link: https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform
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
...

### Lecture 3
...

### Lecture 4
...

## Cleanup
1. Empty S3 bucket using the AWS Console
2. Run `terraform destory`
