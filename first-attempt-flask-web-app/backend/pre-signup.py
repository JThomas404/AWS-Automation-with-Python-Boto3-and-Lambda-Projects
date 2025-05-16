import json
import boto3

def lambda_handler(event, context):
    # Sample pre-signup logic
    print("Event: ", json.dumps(event))

    # You can add any custom validation logic here
    email = event['request']['userAttributes']['email']
    
    # Sample: Check if the email domain is allowed
    allowed_domains = ["example.com", "connectingthedots.com"]
    domain = email.split('@')[1]
    
    if domain not in allowed_domains:
        raise Exception("Invalid email domain. Only @example.com and @connectingthedots.com are allowed.")

    # Allow the user to continue sign-up process
    return event
