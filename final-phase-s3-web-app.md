# Phase 3 – Static Site (S3 + Lambda + API Gateway)

## Project Summary

This phase marks the successful implementation of the web application. After two prior iterations — one tied to a local Flask server and another over-engineered using WSGI — I adopted an architecture that aligns with best practices for cloud engineering. This version cleanly separates concerns across the AWS stack: a static frontend hosted on Amazon S3 and distributed via CloudFront with HTTPS, and a backend API powered by Lambda and API Gateway.

All infrastructure is managed using Terraform, structured to be scalable, modular, and ready for future integrations such as authentication via AWS Cognito.

---

## Overview

The goals of this final version were to:

- Decouple the frontend and backend to improve reliability and maintainability
- Eliminate reliance on Flask and WSGI in favor of native AWS services
- Provide a static, publicly accessible frontend with SSL and custom domain
- Implement a backend capable of processing form submissions and writing to DynamoDB
- Define the infrastructure as code using Terraform for reproducibility and consistency

---

## Tech Stack

| Category        | Technology                          |
|----------------|--------------------------------------|
| Frontend        | HTML, CSS (hosted on S3)            |
| Backend         | Python Lambda Function              |
| API Layer       | Amazon API Gateway                  |
| Database        | Amazon DynamoDB                     |
| Infrastructure  | Terraform (Infrastructure as Code)  |
| CDN + HTTPS     | Amazon CloudFront + ACM             |
| DNS Management  | Amazon Route 53                     |

---

## Folder Structure

```

final-phase-s3-web-app/
├── backend/
│   ├── .serverless/
│   │   ├── cloudformation-template-update-stack.json
│   │   ├── meta.json
│   │   └── serverless-state.json
    ├── .venv/ 
│   ├── app.py
│   ├── requirements.txt
│   ├── serverless.yml
│   └── test-event.json

├── frontend/
│   ├── images/
│   │   ├── CTDC.png
│   │   └── default-profile.png
│   ├── videos/
│   │   └── body-background.mp4
│   ├── contact.html
│   ├── dashboard.html
│   ├── error.html
│   ├── index.html
│   └── style.css

├── terraform/
│   ├── build/
│   │   └── app.py
│   ├── .terraform.lock.hcl
│   ├── api-gateway.tf
│   ├── cloudfront.tf
│   ├── cognito.tf
│   ├── lambda.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── route53.tf
│   ├── terraform.tfvars
│   └── variables.tf

````

---

## Deployment Instructions

**Prerequisites:**
- AWS CLI and Terraform installed
- IAM credentials with permissions to provision required resources

1. **Initialise Terraform:**

```bash
cd terraform
terraform init
````

2. **Validate and apply configuration:**

```bash
terraform plan
terraform apply
```

3. **Upload frontend assets to S3:**

```bash
aws s3 sync ../frontend s3://<your-static-site-bucket>
```

4. **Verify CloudFront distribution and DNS:**

* Confirm HTTPS is enabled
* Confirm site loads at: `https://www.connectingthedotscorp.com`

---

## Key Backend Logic (`backend/app.py`)

```python
import json
import boto3
import urllib.parse

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('contact-submissions')

def lambda_handler(event, context):
    try:
        body = event.get('body', '')
        if event.get('headers', {}).get('Content-Type', '').startswith('application/x-www-form-urlencoded'):
            parsed = urllib.parse.parse_qs(body)
            data = {k: v[0] for k, v in parsed.items()}
        else:
            data = json.loads(body)

        required_fields = ['name', 'email', 'message']
        for field in required_fields:
            if field not in data:
                return {"statusCode": 400, "body": f"Missing field: {field}"}

        table.put_item(Item={
            'email': data['email'],
            'name': data['name'],
            'message': data['message']
        })

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            "body": "Form submission successful"
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Internal server error: {str(e)}"
        }
```

---

## Validation and Testing

### Step 1: Contact Page Form Submission

Form was completed on the live frontend and submitted to the `/contact` API Gateway endpoint. The UI returned the expected success message.

![Form Submission - Part 1](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/form-submission-pt1.png)

### Step 2: Network Tab Confirmation

Browser Developer Tools → Network tab confirmed a `200 OK` response with no errors, validating Lambda and API Gateway integration with DynamoDB.

![Form Submission - Part 2](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/form-submission-pt2.png)

---

## Features

* Static frontend hosted securely on S3, served via CloudFront
* HTTPS support and custom domain with ACM and Route 53
* API Gateway exposes `/contact` and `/userdata` routes
* Lambda function handles form processing and DynamoDB storage
* Full infrastructure defined in modular, versioned Terraform code
* CORS compliant and browser-tested endpoint integration
* Client-side success messages and cleared form state

---

## Lessons and Takeaways

**Native AWS Architecture Simplified Deployment and Debugging**
By using S3, Lambda, and API Gateway directly, I eliminated unnecessary middleware and reduced complexity. Debugging and scaling became faster and more predictable.

**Terraform Provided Reproducibility and Modularity**
Terraform enabled structured and consistent infrastructure provisioning across all environments — with version control, visibility, and rollback safety.

**Static Frontends Paired with Dynamic APIs Work at Scale**
Separating the frontend removed the need for a web server. This serverless model runs compute only on-demand and leverages global CDN distribution.

**CORS, DNS, and HTTPS Integration Require Careful Attention**
I gained experience managing detailed configuration across multiple AWS services — ensuring secure, performant, and accessible endpoints.

**Architecture Ready for Future Extensions**
This version is future-proof. It can integrate authentication (Cognito), enhanced logging (CloudWatch), and automated cleanups (S3 lifecycle rules) without major refactors.

---

## Transition from Phase 2

This version resolves the architectural and deployment challenges encountered in the previous two phases. It delivers a scalable, secure, and maintainable cloud application using fully managed AWS services.

For a full breakdown of the challenges resolved and lessons learned, see:

[Challenges and Learnings](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/challenges-and-learnings.md)

---