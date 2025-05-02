# Challenges and Learnings – ConnectingTheDots Project

This document outlines key technical challenges encountered during the development and deployment of the serverless web application for ConnectingTheDots, along with solutions and insights gained at each phase.

---

## Phase 1: Infrastructure Setup Challenges

### 🔍 S3 Public Access Denied
- **Issue**: After deploying the infrastructure, accessing the static website via the S3 bucket returned "Access Denied" or XML-format errors.
- **Root Cause**: AWS's default S3 security settings block public access unless explicitly allowed.
- **Fix**: Public access was correctly enabled using Terraform configurations for access block overrides and a bucket policy:

```hcl
resource "aws_s3_bucket_public_access_block" "public-access" {
  bucket                  = aws_s3_bucket.ctd-s3-bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "allow-public-access-on-bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.ctd-s3-bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.ctd-s3-bucket.id
  policy = data.aws_iam_policy_document.allow-public-access-on-bucket.json
}
```

### 🧭 Missing Static Website Configuration
- **Issue**: The static website did not render.
- **Diagnosis**: The S3 bucket lacked the configuration for an index and error document.
- **Fix**: Added a `website_configuration` block:

```hcl
resource "aws_s3_bucket_website_configuration" "ctd-website" {
  bucket = aws_s3_bucket.ctd-s3-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
```

### 🧾 IAM Role Failure
- **Issue**: Lambda role creation failed in Terraform.
- **Diagnosis**: Trust policy block syntax was invalid.
- **Fix**: Used `jsonencode()` to dynamically encode a correct trust policy:

```hcl
resource "aws_iam_role" "ctd-lambda" {
  name = "ctd-lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}
```

### 🌐 Bucket Name Conflict
- **Issue**: Terraform errored due to an existing S3 bucket name.
- **Diagnosis**: Bucket names must be globally unique.
- **Fix**: Generated a unique suffix using the `random_id` resource:

```hcl
resource "random_id" "ctd-random-number" {
  byte_length = 8
}

resource "aws_s3_bucket" "ctd-s3-bucket" {
  bucket = "ctd-frontend-${random_id.ctd-random-number.hex}"
}
```

### 🧪 No Outputs for Validation
- **Issue**: Outputs like the S3 website URL were not retrievable.
- **Fix**: Added an `outputs.tf` file:

```hcl
output "s3_website_url" {
  description = "The URL of the S3-hosted website"
  value       = aws_s3_bucket.ctd-s3-bucket.website_endpoint
}
```

---

## Phase 2: Backend API with Flask

### 🕵️ Missing CloudWatch Logs
- **Issue**: No logs were generated for the Lambda function.
- **Diagnosis**: The IAM role lacked permission to publish logs.
- **Fix**: Attached the basic logging policy and provisioned a CloudWatch log group:

```hcl
resource "aws_iam_role_policy_attachment" "ctd-lambda-logs" {
  role       = aws_iam_role.ctd-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/ctd-api"
  retention_in_days = 7
}
```

### 📦 Lambda Packaging Errors
- **Issue**: 500 errors occurred when triggering Lambda.
- **Diagnosis**: Handler was misconfigured or the zip was incomplete.
- **Fix**:
  - Ensured `app.py` was at root.
  - Installed all Python dependencies into `package/`.
  - Zipped both together:

```bash
cd package
zip -r9 ../lambda_function.zip .
cd ..
zip -g lambda_function.zip app.py
```

### 🧭 Deployment Path Errors
- **Issue**: Terraform failed to locate the zip file.
- **Diagnosis**: Wrong relative path.
- **Fix**: Either moved the zip file to Terraform’s directory or updated the path in `main.tf`:

```hcl
filename         = "../lambda_function.zip"
source_code_hash = filebase64sha256("../lambda_function.zip")
```

---

## Phase 3: Static Frontend Deployment

### No Major Issues
- Frontend files (`index.html`, `style.css`, `error.html`) were created and styled.
- Files were uploaded using AWS CLI:

```bash
aws s3 cp frontend/ s3://ctd-frontend-[id]/ --recursive
```

### Validations
- Website loaded from S3.
- `/ping` confirmed backend was alive.
- Error page displayed correctly for invalid URLs.

---

# Phase 4 – Challenges & Learnings: Flask API Deployment with DynamoDB

This phase was my most challenging, as I encountered errors with the lambda function and code not executing correctly to the api. I have documented my process of troubleshooting from debugging, restructuring, and re-deploying the Flask API to work with AWS Lambda and API Gateway.

---

## Error Discovery & Debugging

### Internal Server Error (500)
- After initial deployment, all API routes returned a generic `{"message": "Internal Server Error"}`.
- CloudWatch logs showed `TypeError` originating from `Mangum`, attempting to call Flask with ASGI-style arguments.

### Incompatibility Identified
- Flask is a WSGI-based framework and is not compatible with `Mangum`, which expects ASGI applications.
- This fundamental incompatibility caused runtime errors.

### Logging Issues
- No logs were being generated in CloudWatch initially.
- Solution:
  - Added the managed `AWSLambdaBasicExecutionRole` to the Lambda IAM role.
  - Explicitly created a log group `/aws/lambda/ctd-api` using Terraform to ensure proper logging.

---

## Fixes & Rebuild

### Switching from Mangum to Serverless-Wsgi
- Removed `Mangum` from the project entirely.
- Created a new file `wsgi_handler.py` with the following contents:

```python
from app import app
from serverless_wsgi import handle_request

def handler(event, context):
    return handle_request(app, event, context)
```

- This approach is compatible with WSGI applications like Flask and bridges them to Lambda's event-driven model.

### Cleaning & Rebuilding Deployment Package
- Deleted outdated and duplicate files/directories:
  - `lambda_function.zip`
  - `deployment/`, `.DS_Store`, `venv/`, `__pycache__/`

- Reinstalled dependencies into a fresh `package/` directory:

```bash
pip install flask boto3 serverless-wsgi -t package/
```

- Packaged application:
  - Root:
    - `wsgi_handler.py`
    - `package/` directory containing all dependencies
  - Zipped into `lambda_function.zip`

### Terraform Updates
- Updated Lambda function handler in `main.tf`:

```hcl
handler = "wsgi_handler.handler"
```

- Verified correct zip file path:

```hcl
filename         = "lambda_function.zip"
source_code_hash = filebase64sha256("lambda_function.zip")
```

- Ensured IAM role had:
  - `AWSLambdaBasicExecutionRole` for logging
  - `AmazonDynamoDBReadOnlyAccess` for reading from the DynamoDB table

### Redeployment
- Re-applied the Terraform plan:

```bash
terraform apply
```

- Lambda deployed successfully
- Connected to API Gateway via integration and route

---

## Validation & Confirmation

### API Tested Successfully
- Accessed `/` endpoint via API Gateway
- Received the expected response:

```json
{"message": "Welcome to ConnectingTheDots!"}
```

### CloudWatch Logs Verified
- Logs successfully recorded request and response cycles

**The successful response for documentation purposes**
![api-welcome-message.png](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/welcome-message.png)

---

## Phase 5: Frontend Setup with Flask

### ❌ ModuleNotFoundError: No module named 'serverless_wsgi'

- **Issue**: After setting up the initial Flask application and attempting to run the development server using `flask run`, the following error was encountered:

```bash
ModuleNotFoundError: No module named 'serverless_wsgi'
```

- **Cause**: The `serverless_wsgi` library was not installed in the local virtual environment. This module is essential to bridge Flask (a WSGI app) with AWS Lambda's event-based execution.

- **Resolution**:
  1. Activated the virtual environment:

     ```bash
     source .venv/bin/activate
     ```

  2. Installed the missing package:

     ```bash
     pip install serverless-wsgi
     ```

  3. Verified that the application now runs without error:

     ```bash
     flask run
     ```

- **Learning**: Always ensure all required packages are installed and available in the current virtual environment. This error reinforced the importance of managing dependencies correctly and checking for missing imports early in the setup process.

---

## Phase 6: Contact Form Integration with DynamoDB

This phase involved implementing a working contact form that captures user submissions from the frontend and stores them in DynamoDB via a Flask backend served through AWS Lambda.

---

### Issue: `ResourceNotFoundException` – DynamoDB Table Not Found

**Error Message:**
```json
{
  "error": "An error occurred (ResourceNotFoundException) when calling the PutItem operation: Requested resource not found"
}
```

**Cause:**
The Lambda function was trying to write data to a non-existent or incorrectly named DynamoDB table. The backend code was pointing to:
```python
table = dynamodb.Table("ConnectingTheDotsContactTable")
```
…but the table created in Terraform was actually named:
```hcl
resource "aws_dynamodb_table" "ctd-db" {
  name = "ConnectingTheDotsDBTable"
}
```

**Fix:**
Updated the Python Flask code to reference the correct table:
```python
table = dynamodb.Table("ConnectingTheDotsDBTable")
```

---

### Issue: Required Fields Validation Missing

The form allowed empty submissions and returned vague backend responses.

**Fix:**
Implemented basic validation in the `/submit_contact` route:
```python
if not first_name or not last_name or not email:
    return jsonify({"error": "Required fields are missing"}), 400
```

---

### Issue: IAM Role Lacked Write Access to DynamoDB

**Symptoms:**
The Lambda function had permission issues when writing to the table.

**Fix:**
Added this IAM policy attachment in `main.tf` to grant write access:
```hcl
resource "aws_iam_role_policy_attachment" "ctd-dynamodb-write" {
  role       = aws_iam_role.ctd-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
```

> Note: This was granted for development. Consider using scoped-down permissions in production.

---

### Issue: Repackaging and Deploying Lambda Zip Incorrectly

**Problem:**
After modifying the backend, the `lambda_function.zip` was not repackaged properly, resulting in outdated logic being deployed.

**Fix:**
Repackaged with updated dependencies and app files:

```bash
# Activate virtual environment
source .venv/bin/activate

# Reinstall necessary packages
pip install flask boto3 serverless-wsgi -t package/

# Package everything into a fresh ZIP
cd package
zip -r9 ../lambda_function.zip .
cd ..
zip -g lambda_function.zip app.py
```

---

### Verification

- **Successful Form Submission**: Confirmed contact data written to DynamoDB.
- **Test Screenshots**:
  - ![contact-form-message.png](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/contact-form-message.png)
  - ![form-items-saved-1.png](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/form-items-saved-1.png)
  - ![form-items-saved-2.png](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/form-items-saved-2.png)

---
