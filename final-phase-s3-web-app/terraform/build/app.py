import json
import boto3
import urllib.parse
import traceback
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Lambda event received: %s", json.dumps(event))

    # Handle CORS preflight
    if event.get('httpMethod') == 'OPTIONS':
        return cors_response(200, "CORS preflight OK")

    path = event.get('path', '')

    try:
        if path == '/contact':
            return handle_contact(event)
        elif path == '/userdata':
            return handle_userdata_stub(event)
        else:
            logger.warning("Unhandled path: %s", path)
            return cors_response(404, {"error": "Not Found"})

    except Exception as e:
        logger.error("Exception occurred: %s", str(e))
        logger.error(traceback.format_exc())
        return cors_response(500, {"error": "Internal server error"})

def handle_contact(event):
    content_type = event["headers"].get("Content-Type") or event["headers"].get("content-type", "")
    body = event.get("body", "")

    if "application/json" in content_type:
        body = json.loads(body)
    elif "application/x-www-form-urlencoded" in content_type:
        parsed = urllib.parse.parse_qs(body)
        body = {k: v[0] for k, v in parsed.items()}
    else:
        logger.warning("Unsupported content type: %s", content_type)
        body = {}

    logger.info("Parsed body: %s", json.dumps(body))

    # Extract fields
    first_name = body.get("first_name")
    last_name = body.get("last_name")
    job_title = body.get("job_title")
    phone_number = body.get("phone_number")
    email = body.get("email")
    company = body.get("company")

    # Validate required fields
    if not first_name or not last_name or not email:
        logger.warning("Missing required fields: first_name, last_name, email")
        return cors_response(400, {"error": "First name, last name, and email are required."})

    # Log payload before writing to DynamoDB
    item = {
        "email": email,
        "first_name": first_name,
        "last_name": last_name,
        "job_title": job_title,
        "phone_number": phone_number,
        "company": company
    }

    logger.info("Attempting DynamoDB put_item with data: %s", json.dumps(item))

    try:
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table("ConnectingTheDots")
        table.put_item(Item=item)

        logger.info("DynamoDB put_item succeeded for email: %s", email)
        return cors_response(200, {"message": "Contact data stored successfully"})

    except Exception as db_error:
        logger.error("DynamoDB put_item failed: %s", str(db_error))
        return cors_response(500, {"error": "Failed to store contact data"})

def handle_userdata_stub(event):
    # Stub function since JWT is removed
    logger.info("handle_userdata called, but JWT removed. Returning dummy data.")
    return cors_response(200, {
        "first_name": "Test",
        "last_name": "User",
        "email": "test@example.com",
        "picture": ""
    })

def cors_response(status_code, body, methods="POST,OPTIONS"):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": methods,
            "Access-Control-Allow-Headers": "Content-Type,Authorization"
        },
        "body": json.dumps(body)
    }
