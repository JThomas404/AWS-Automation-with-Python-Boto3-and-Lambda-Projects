# Challenges and Learnings

This document outlines the major technical and architectural challenges encountered during the development of the Serverless Web Application Project. Each challenge is presented with context, resolution steps, relevant code or error references, and the resulting insights.

---

## Phase 1 – Flask (Localhost)

### 1. Application Runtime Bound to Localhost

**Challenge:**  
The Flask app was only available while the local development server was running. Once the terminal was closed or the session ended, the app became inaccessible.

**Example Workflow:**

```bash
$ python app.py
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
````

**Learning:**
This limitation made it clear that I needed a backend architecture capable of running independently in the cloud, decoupled from developer sessions.

---

### 2. AWS Credential and Region Misconfiguration

**Challenge:**
The Flask app failed silently when attempting to write to DynamoDB due to missing AWS region and improperly configured credentials.

**Initial Code (bugged):**

```python
dynamodb = boto3.resource('dynamodb')
```

**Error:**

```
botocore.exceptions.NoRegionError: You must specify a region.
```

**Fix:**

```python
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
```

**Learning:**
Boto3 requires explicit configuration for region and credentials. Environment setup matters as much as application logic, especially in local testing.

---

### 3. Secrets Handled Insecurely

**Challenge:**
Credentials were briefly hardcoded during testing:

```python
aws_access_key_id = "AKIA..."
aws_secret_access_key = "abc123..."
```

**Fix:**
Replaced with environment-based credential loading and ensured sensitive files (e.g., `.env`, `venv/`) were excluded via `.gitignore`.

**Learning:**
Even in prototyping, security cannot be an afterthought. Proper credential management must be enforced from day one to avoid critical missteps.

---

## Phase 2 – Serverless Flask with WSGI

### 1. Lambda + WSGI Obscured Errors

**Challenge:**
Deploying Flask via `serverless-wsgi` resulted in generic 502 errors, masking the root cause of Lambda failures.

**API Response:**

```json
502 Bad Gateway
{"message": "Internal server error"}
```

**CloudWatch Logs:**

```
Unable to import module 'wsgi_handler': No module named 'flask'
```

or

```
botocore.exceptions.ParamValidationError: Parameter validation failed
```

**Fix:**
Added structured `try/except` logic and verbose logging, but the WSGI abstraction still limited traceability.

**Learning:**
`serverless-wsgi` introduces an opaque layer that hinders effective debugging. It obscures stack traces and runtime failures behind middleware complexity.

---

### 2. Broken CORS on Browser Submissions

**Challenge:**
Browser requests were blocked due to CORS misconfigurations.

**Browser Console Error:**

```
Response to preflight request doesn't pass access control check.
Access to fetch at 'https://xyz.execute-api.amazonaws.com/dev/contact' from origin 'https://localhost' has been blocked by CORS policy.
```

**Fixes:**

**In Flask:**

```python
response.headers.add("Access-Control-Allow-Origin", "*")
response.headers.add("Access-Control-Allow-Headers", "Content-Type")
response.headers.add("Access-Control-Allow-Methods", "POST, OPTIONS")
```

**In serverless.yml:**

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
CORS must be configured both in the application response and API Gateway method response definitions. Relying on Flask alone is insufficient.

---

### 3. Packaging Errors and Lambda Size Bloat

**Challenge:**
Deployments failed due to oversized zipped packages and unnecessary dependencies.

**Error:**

```
Unzipped size must be smaller than 262144000 bytes
```

**Cause:**
The full `venv` was mistakenly included in the packaged zip.

**Fix:**

```yaml
custom:
  pythonRequirements:
    dockerizePip: true
    zip: true
    slim: true
```

**Learning:**
Lambda deployments must remain lean. Extra dependencies inflate deploy times, reduce portability, and often exceed AWS limits.

---

## Phase 3 – Static Site (S3 + Lambda + API Gateway)

### 1. API Gateway Returning CORS Errors Despite Lambda Headers

**Challenge:**
Even with correct headers in the Lambda response, CORS errors persisted in the browser.

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
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}
```

**Learning:**
CORS is enforced at the API Gateway method and integration layers. Lambda headers alone do not suffice.

---

### 2. SSL and DNS Misconfiguration

**Challenge:**
CloudFront returned 403 errors, and ACM certificate validation remained stuck in a pending state.

**Symptoms:**

* `403 Forbidden` on the domain
* No SSL padlock
* ACM validation not completing

**Fixes:**

* Route 53 alias record updated to correct CloudFront distribution
* `_acme-challenge` CNAME record added for domain verification

**Learning:**
CloudFront, ACM, and Route 53 must be tightly aligned. Even small mismatches in hosted zone IDs or record targets can prevent propagation.

---

### 3. HTML Form Submissions Using `application/x-www-form-urlencoded`

**Challenge:**
Lambda was written to parse JSON but failed on legacy form encoding.

**Bug:**

```python
data = json.loads(event['body'])  # fails for HTML form submissions
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
HTML forms still default to `x-www-form-urlencoded`. Supporting multiple content types improves frontend compatibility and flexibility.

---

### 4. CloudFront–S3 Access Errors

**Challenge:**
Static assets uploaded to S3 returned 403 errors when served through CloudFront.

**Error:**

```
403 Forbidden - CloudFront cannot access the origin
```

**Cause:**
CloudFront was not authorized to access the S3 bucket via Origin Access Control (OAC).

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
For private buckets, CloudFront must be explicitly granted access via a valid OAC and matching policy. Otherwise, requests fail silently at the edge.

![Frontend Error](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/raw/main/images/frontend.png)

---

## Conclusion

These were not surface-level bugs. They were architectural blind spots and misunderstandings — across networking, IAM, deployment, HTTP, and infrastructure-as-code. Solving them required reading documentation, testing hypotheses, and building deeper familiarity with AWS’s event-driven ecosystem.

The outcome is not just a working application, but a maturing skillset in building scalable, secure, and observable cloud systems. These challenges taught me how to think like a cloud engineer should — methodically, modularly, and with an eye toward practical reliability.

---