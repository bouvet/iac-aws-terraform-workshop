import json
import boto3
import os

DB_NAME = os.environ["DB_NAME"]


def lambda_handler(event, context):
  dynamodb = boto3.resource('dynamodb', region='eu-central-1')

  table = dynamodb.Table(DB_NAME)

  response = table.scan()
  data = response['Items']

  while 'LastEvaluatedKey' in response:
    response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
    data.extend(response['Items'])

  return {
    "statusCode": 200,
    "body": json.dumps(data),
    'headers': {
      'Access-Control-Allow-Origin': '*'
    }
  }
