def lambda_handler(event, context):
  print("Success!!!")

  return {
    "statusCode": 200,
    "body": {"message": "success!!!"}
  }
