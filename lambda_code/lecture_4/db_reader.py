import json
import boto3
import os

DB_NAME = os.environ["DB_NAME"]


def lambda_handler(event, context):

  dynamodb = boto3.resource("dynamodb")
  table = dynamodb.Table(DB_NAME)

  print(f"getting bird with id: {event['pathParameters']['id']}")

  response = table.get_item(Key={"id": event["pathParameters"]["id"]})

  return {
    "statusCode": 200,
    "body": json.dumps(response["Item"]),
    'headers': {
      'Access-Control-Allow-Origin': '*'
    }
  }
