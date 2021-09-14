import json
import os
import boto3

DB_NAME = os.environ["DB_NAME"]
S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]


def lambda_handler(event, context):
  filename = event['Records'][0]['s3']['object']['key']

  s3 = boto3.resource('s3')
  file = s3.Object(S3_BUCKET_NAME, filename).get()

  file_content = json.load(file["Body"])

  dynamodb = boto3.resource('dynamodb')
  table = dynamodb.Table(DB_NAME)

  for bird in file_content:
    table.put_item(Item=bird)