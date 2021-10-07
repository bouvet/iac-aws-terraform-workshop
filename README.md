# IaC AWS Terraform Workshop
This repository contains code used for a workshop about IaC using Terraform.

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


#### Fist time login to the AWS Console
1. See if you have received AWS credentials from the course leader (you should receive this shortly before the course start).
   1. This should contain username and password for the AWS Console and access keys.
2. Go to the [AWS Console](https://eu-central-1.console.aws.amazon.com).
3. Choose to sign in as IAM user and type in `bouvet-ost-tech1` as AccountID and hit "Next".
4. Under "IAM user name" and "Password" type in the username and password you received from the course leader.
5. Create a new password.


### Lecture 1
In this lecture you should configure the AWS CLI, initiate terraform and deploy an S3 Bucket.

> Keep in mind that all the participants in this workshop will use the same AWS account, so try to give your resources names that you can easily identify.

1. Configure aws: 
   1. Run `aws configure` 
   2. Type in your personal access keys (`Access Key ID` and `Secret Access Key`) you received from the course leader. 
   3. When asked about default region type: `eu-central-1` and set default output format to `json`.
2. Clone this repository
3. Open the code in your editor of choice.
4. Set S3 bucket name: Open the [variables.tf](variables.tf) file and change the `s3_bucket_name` value from `<YOUR_BUCKET_NAME>`, to whatever you want to call your S3 bucket.
5. While in the [variables.tf](variables.tf) file, update the value in the `my_name` variable to your own name (without spaces).
6. Open [lecture_1.tf](lecture_1.tf) and read the instructions to set the S3 bucket name.
7. Initiate Terraform: Open your terminal in the project folder and run `terraform init`.
8. Preview what will happen if you deploy this code: `terraform plan`.
9. Deploy your S3 bucket: `terraform apply` (when asked if you want to apply this code, type `yes` and hit enter).
10. Login to the [AWS Console and find your S3 bucket](https://s3.console.aws.amazon.com/s3/home?region=eu-central-1). Try uploading any text file to this bucket.


### Lecture 2
In this lecture we will create a lambda function that will run every time a file is uploaded to our S3 bucket.

> All the lambda function code for each lecture can be found under [lambda_code](lambda_code).

1. Uncomment the code in [lecture_2.tf](lecture_2.tf).
2. Open the the [variables.tf](variables.tf) file and make sure the `s3_consumer_lambda_function_code_path` variable is pointing to the folder containing the python code for lecture 2. The path should be as follows: `./lambda_code/lecture_2`.
3. Go to [lecture_2.tf](lecture_2.tf), find the aws lambda function configuration, under environment variables update the S3 bucket variable to point to the bucket name variable in [variables.tf](variables.tf).
4. Run `terraform init` to import the archive plugin.
5. Preview the changes: `terraform plan`
6. Deploy changes: `terraform apply`
7. Upload a new file to the S3 bucket.
8. View logs (it can take a few minutes (1-2) before logs are showing):
   1. Open the Lambda function in the AWS Console. 
   2. Click on monitoring and view the Lambda Function logs in CloudWatch. 
   3. Open the CloudWatch log stream, and you should see that our application has run and printed a message saying: `success!!!`.


### Lecture 3
In this lecture we will create a DynamoDB table and update our lambda function to consume files uploaded to S3 and store the content in the DynamoDB table.
> The Lambda function will only support json lists, so use the file provided [here](lambda_code/birds.json) when uploading to the S3 bucket.

1. Uncomment the code in [lecture_3.tf](lecture_3.tf).
2. Set DynamoDB table name: Open the [variables.tf](variables.tf) file and change the `dynamodb_table_name` value from `<YOUR_TABLE_NAME>`, to whatever you want to call your DynamoDB table.
3. In [variables.tf](variables.tf) update the `s3_consumer_lambda_function_code_path` variable to point to the python for lecture three. The path should be as follows: `./lambda_code/lecture_3`.
4. Go into the [lecture_2.tf](lecture_2.tf) file, find the aws lambda function configuration, under environment variables update the DB_NAME variable to get the database name from the terraform resource: `my_dynamodb_table` located in [lecture_3.tf](lecture_3.tf).
   1. In the example bellow `birds_resource` retrieves two properties from the `birds_api` resource:

   ```terraform
    resource "aws_api_gateway_rest_api" "birds_api" {
      name = "birds_api"
    }

    output "birds_resource" {
      value = aws_api_gateway_rest_api.birds_api.name
    }
    ```
5. Preview the changes: `terraform plan`
6. Deploy changes: `terraform apply`
7. Upload the [json file](lambda_code/birds.json) to your S3 bucket.
8. Open the DynamoDB table in the AWS Console. The content of the file should now be stored in the DynamoDB table.


### Lecture 4
In this lecture we will create a lambda function which can get a single object from the database, given an id. 
We will then create an API Gateway where we will add an endpoint connected to the lambda function. 
This way we will be able to hit an API endpoint and get an object from the database in return.

1. Uncomment the code in [lecture_4.tf](lecture_4.tf), including the line comment on line: 128.
2. In the [lecture_4.tf](lecture_4.tf) file find the `api_gateway_invoke_db_reader_lambda_permission` and under `function_name`, get the lambda function name from the `db_reader_lambda`.
3. Anywhere in the [lecture_4.tf](lecture_4.tf) file create an [terraform output](https://www.terraform.io/docs/language/values/outputs.html) with the value of the `demo_env` invoke URL.
4. Find the `birds_resource` resource in [lecture_4.tf](lecture_4.tf) and add a string path under `path_part`. Try to keep it simple without any special characters, like "birds" or something.
5. Preview the changes: `terraform plan`
6. Deploy changes: `terraform apply`
7. The URL you can use to access the API should be printed in the terminal. Copy that URL and paste it in your web browser, followed by `/` and the path you wrote in step 4, followed by `/` and an object id provided in the [json file](lambda_code/birds.json). The complete URL should look something like this: https://xk5x3cs7ik.execute-api.eu-central-1.amazonaws.com/demo/birds/079b42b8-a1ab-11eb-bcbc-0242ac130002.
8. See if you get a JSON object in return from the URL in step 7. If so, then you have a working API 👏🏼.


### Extra 🤓
In this lecture you should create your own terraform code to add a new endpoint to the existing API from lecture 4. 
This endpoint should be of type HTTP GET, and should return a JSON list of all the objects in the database. 
You will find the python code in [this folder](lambda_code/lecture_extra).

> Keep in mind that every terraform resource has to have a unique set of labels (type and name). 
> This is important for this lecture since you are going to create multiple new terraform resources of the same type.

1. Create a new `.tf` file in the project root folder.
2. In your new terraform file, add all the necessary terraform code for a lambda function (TIP: copy much of the code from [lecture_4.tf](lecture_4.tf)).
   1. You can reuse the `db_reader_lambda_iam_role` since this contains all the access you need.
   2. In your `aws_lambda_function` make sure to use "get_all_birds.lambda_handler" as `handler`.
   3. In your `archive_file`, point to the correct folder where the code is stored.
3. Create your API endpoint: Since the API is created beforehand you only need to create three new resources based on the one in [lecture_4.tf](lecture_4.tf):
   1. `aws_api_gateway_method`: Change the `resource_id` to point to the root resource: `birds_resource` and remove request_parameters.
   2. `aws_api_gateway_integration`: Change these parameters accordingly: `http_method`, `resource_id` and `uri`.
   3. `aws_lambda_permission`: `function_name` should point to your new lambda function definition.
4. Preview the changes: `terraform plan`
5. Deploy changes: `terraform apply`
6. Test your new endpoint to retrieve a list of objects.

## Cleanup 🧹
1. Empty S3 bucket using the AWS Console
2. Run `terraform destory`
