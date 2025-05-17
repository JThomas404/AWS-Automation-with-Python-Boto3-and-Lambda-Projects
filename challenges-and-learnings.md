# Challenges and Learnings

This document outlines the major technical and architectural challenges encountered throughout the development of the Serverless Web Application Project. Each challenge is explained with context, resolution steps, code and error references, and the lessons I have extracted from each relevant challenge.

---

## Phase 1 – Flask (Localhost)

### 1. Application Runtime Bound to Localhost

**Challenge:**  
The Flask app was only available while the development server was manually running. Closing the terminal or breaking the session immediately made the application inaccessible.

**Resulting Workflow:**

```bash
$ python app.py
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
````

No remote access. No resilience.

**Learning:**
This made it clear that I needed a cloud-deployable backend that could run independently of a developer session.

---

### 2. AWS Credential and Region Misconfiguration

**Challenge:**
The Flask app silently failed when attempting to write to DynamoDB because AWS credentials were not configured and the region was not explicitly passed.

**Initial Code (bugged):**

```python
dynamodb = boto3.resource('dynamodb')
```

**Error (CloudWatch or CLI output):**

```
botocore.exceptions.NoRegionError: You must specify a region.
```

**Fix:**

```python
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
```

**Learning:**
Boto3 requires explicit environment configuration — region, credentials, and IAM role alignment — especially in local testing.

---

### 3. Secrets Handled Insecurely

**Challenge:**
Temporary tests included hardcoded AWS credentials:

```python
aws_access_key_id = "AKIA..."
aws_secret_access_key = "abc123..."
```

**Resolution:**
Replaced with environment variable-based credential loading and ensured `.gitignore` excluded `.env`, `venv/`, and any credential artifacts.

**Learning:**
Security hygiene is not optional, even during prototyping. It is easy to accidentally commit sensitive information without proper version control practices.

---

## Phase 2 – Serverless Flask with WSGI

### 1. Lambda + WSGI Obscured Errors

**Challenge:**
Once Flask was deployed via `serverless-wsgi`, Lambda returned only vague 502 errors for any internal exception.

**API Response:**

```
502 Bad Gateway

{"message": "Internal server error"}
```

**CloudWatch Logs:**

```
Unable to import module 'wsgi_handler': No module named 'flask'
```

or

```
Traceback (most recent call last):
  ...
  File "app.py", line 23, in contact
    table.put_item(Item=data)
botocore.exceptions.ParamValidationError: Parameter validation failed: ...
```

**Fix:**
Wrapped all form parsing and DynamoDB logic in structured try/except with logging, but ultimately WSGI continued to mask stack traces.

**Learning:**
The WSGI abstraction layer created by `serverless-wsgi` made debugging fragile. It became a bottleneck for error traceability.

---

### 2. Broken CORS on Browser Submissions

**Challenge:**
Submitting a form from the frontend resulted in blocked preflight requests due to missing headers or unhandled `OPTIONS` requests.

![Frontend Error](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/raw/main/images/frontend.png)

**Browser Console Error:**

```
Access to fetch at 'https://xyz.execute-api.amazonaws.com/dev/contact'
from origin 'https://localhost' has been blocked by CORS policy.
Response to preflight request doesn't pass access control check.
```

**Fix (in Flask):**

```python
response.headers.add("Access-Control-Allow-Origin", "*")
response.headers.add("Access-Control-Allow-Headers", "Content-Type")
response.headers.add("Access-Control-Allow-Methods", "POST, OPTIONS")
```

**Fix (in serverless.yml):**

```yaml
functions:
  app:
    handler: wsgi_handler.handler
    events:
      - http:
          path: /
          method: options
```

**Learning:**
CORS must be handled both in application responses and in API Gateway’s HTTP method configuration. Flask is not CORS-aware by default.

---

### 3. Packaging Errors and Size Bloat

**Challenge:**
Deploying the Flask app via Serverless often failed due to Python packaging errors or zip files exceeding Lambda size limits.

**Error:**

```
An error occurred: Unzipped size must be smaller than 262144000 bytes
```

or

```
Unable to import module 'wsgi_handler': No module named 'flask'
```

**Cause:**
The entire `venv` directory was being zipped along with the source, including unnecessary packages.

**Fix:**
Used the `serverless-python-requirements` plugin with proper exclusions and Docker packaging:

```yaml
custom:
  pythonRequirements:
    dockerizePip: true
    zip: true
    slim: true
    strip: false
```

**Learning:**
Lambda functions must remain lightweight. Large deployments delay iteration and increase complexity unnecessarily.

---

## Phase 3 – Static Site (S3 + Lambda + API Gateway)

### 1. API Gateway Returning CORS Errors Despite Lambda Headers

**Challenge:**
Even after adding correct CORS headers in the Lambda response, the browser still failed preflight checks.

**Lambda Output:**

```json
"headers": {
  "Access-Control-Allow-Origin": "*"
}
```

**Browser Error:**

```
Response to preflight request does not include access-control-allow-origin header
```

**Fix (Terraform):**

```hcl
resource "aws_api_gateway_method_response" "cors" {
  ...
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}
```

**Learning:**
Lambda alone is not responsible for CORS. The integration and method response layers in API Gateway must echo CORS headers explicitly.

---

### 2. SSL and DNS Misconfiguration

**Challenge:**
CloudFront served the wrong S3 distribution. Route 53 `A` records pointed to an incorrect CloudFront distribution, and ACM certificate validation failed.

**Symptoms:**

* `403 Forbidden` from CloudFront
* No SSL lock on the domain
* Certificate in ACM showed `Pending validation`

**Fix:**

* Updated Route 53 alias record to the correct CloudFront distribution
* Added the missing `_acme-challenge` CNAME record to Route 53

**Learning:**
CloudFront, Route 53, and ACM must be precisely coordinated. Even minor mismatches in hosted zone records or distribution IDs can cause propagation or validation failure.

---

### 3. HTML Form Encoded Data Not Parsed

**Challenge:**
Lambda was expecting JSON, but the form submitted `application/x-www-form-urlencoded`, resulting in missing keys in the request body.

**Buggy Lambda Code:**

```python
data = json.loads(event['body'])  # Fails on form-encoded input
```

**Fix:**

```python
import urllib.parse

if headers.get("Content-Type", "").startswith("application/x-www-form-urlencoded"):
    data = urllib.parse.parse_qs(event['body'])
    data = {k: v[0] for k, v in data.items()}
else:
    data = json.loads(event['body'])
```

**Learning:**
Lambda APIs must support multiple content types. Browsers still default to legacy formats in plain HTML forms. Supporting them improves compatibility and user experience.

---

### 4. S3 Permissions and CloudFront Integration

**Challenge:**
Static assets were uploaded to S3, but requests returned 403 errors when accessed via CloudFront.

**Error:**

```
403 Forbidden - CloudFront cannot access the origin
```

**Root Cause:**
The S3 bucket policy did not allow CloudFront (via OAC) to access the files.

**Fix (Terraform):**

```hcl
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  policy = jsonencode({
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "arn:aws:s3:::bucket-name/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}
```

**Learning:**
Secure S3 access via CloudFront requires correctly configured origin access control and matching bucket policies. Misalignment results in blocked content at the edge.

---

## Conclusion

Each of these challenges forced me to stop, reassess, and understand the deeper mechanics of the AWS services I was using. These were not shallow bugs — they were foundational misunderstandings that had to be corrected through deliberate learning, reading documentation, debugging logs, and testing in isolation.

These experiences taught me to:

* Design for cloud-native environments instead of adapting server-based tools
* Write secure, minimal, and content-aware Lambda functions
* Configure and debug AWS infrastructure with precision using Terraform
* Treat CORS, DNS, SSL, and IAM as core components — not afterthoughts

Overcoming these problems did not just result in a working application. It gave me the confidence and experience to design, build, and maintain production-grade serverless architectures in AWS.

This project became a lesson in engineering resilience — and in building systems that are not only functional, but sustainable.

---