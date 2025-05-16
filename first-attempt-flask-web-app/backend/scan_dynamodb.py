# Test script to verify if Lambda (via Python) can retrieve items from DynamoDB
# This logic will later be integrated into the Flask app (app.py)
import boto3

client = boto3.client('dynamodb')

paginator = client.get_paginator('list_tables')
paginator_iterator = paginator.paginate()

for page in paginator_iterator:
    print(page['TableNames'])

response = client.scan(TableName='ConnectingTheDotsDBTable')
print(response['Items'])