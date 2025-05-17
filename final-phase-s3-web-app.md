# Phase 3 – Static Site (S3 + Lambda + API Gateway)

## Project Summary

This phase marks the successful implementation of the web application. After two prior iterations — one tied to a local Flask server and another over-engineered using WSGI — I opted for a cloud-native architecture that separates concerns cleanly across the AWS stack. This version delivers a static frontend hosted on Amazon S3, served via CloudFront with HTTPS, and a backend API powered by Lambda and API Gateway.

The infrastructure is fully managed through Terraform and structured to be scalable, modular, and ready for future integrations such as authentication via AWS Cognito.

---

## Overview

The goals of this final version were:

- Decouple frontend and backend to improve reliability and maintainability
- Eliminate reliance on Flask and WSGI in favor of native AWS components
- Provide a static, publicly accessible frontend with SSL and custom domain
- Implement a backend capable of processing form submissions and writing to DynamoDB
- Define the infrastructure as code using Terraform to ensure reproducibility and consistency

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
│   └── app.py                  # Lambda function logic
├── frontend/
│   ├── index.html              # Home page
│   ├── contact.html            # Contact form
│   ├── dashboard.html          # (Future) Authenticated dashboard
│   └── style.css               # Styling
├── terraform/
│   ├── main.tf                 # Root module
│   ├── api-gateway.tf          # API Gateway configuration
│   ├── cloudfront.tf           # CloudFront and S3 hosting
│   ├── lambda.tf               # Lambda + IAM
│   ├── route53.tf              # DNS records
│   └── variables.tf            # Input variables
└── README.md                   # Primary documentation

````

---

## Deployment Instructions

**Prerequisites:**
- AWS CLI and Terraform installed
- Proper IAM credentials configured

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

4. **Verify CloudFront distribution and DNS propagation:**

* Ensure HTTPS is active
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

Once deployed, I verified the contact form by navigating to the live site and submitting test data.

### Step 1: Form Submission from Contact Page

I completed the form on the live frontend and submitted it via the hosted `/contact` API Gateway endpoint. The UI returned the expected success message.

![Form Submission - Part 1](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/form-submission-pt1.png)

---

### Step 2: Inspect Element Network Tab Confirmation

Using the browser's Developer Tools → Network tab, I confirmed that the request was sent successfully. The response returned a `200 OK` with no errors, verifying that Lambda, API Gateway, and DynamoDB integration was functioning correctly.

![Form Submission - Part 2](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/form-submission-pt2.png)

---

## Features

* Static site hosted securely on S3 and distributed globally via CloudFront
* HTTPS and custom domain (`www.connectingthedotscorp.com`) using ACM
* API Gateway exposed `/contact` and `/userdata` resources
* Lambda handles backend logic and integrates with DynamoDB
* Terraform-defined infrastructure across all layers
* CORS headers properly configured for browser compatibility
* Successful form submission triggers a success message and clears form state

---

## Lessons and Takeaways

**Cloud-Native Design Simplified Deployment and Debugging**
By using S3, Lambda, and API Gateway directly, I eliminated unnecessary middleware and reduced failure points. Debugging, deployment, and scaling became easier and more predictable.

**Terraform Allowed Infrastructure Reusability and Consistency**
Using Terraform for the entire project allowed consistent environment replication, version control, and streamlined change management.

**Static Frontends + Dynamic APIs Are Powerful**
Decoupling the frontend removed the need for Flask or a web server. This architecture allowed a truly serverless model — where compute only runs on-demand, and the frontend is globally cached.

**CORS, HTTPS, and DNS Require Careful Integration**
Ensuring clean cross-origin access, end-to-end encryption, and domain resolution highlighted the importance of low-level configuration in production systems.

**This Architecture Scales Forward**
The current build supports the planned integration of AWS Cognito for authentication, CloudWatch for monitoring, and S3 lifecycle rules for cost optimisation — without requiring structural changes.

---

## Transition from Phase 2

This phase resolved the core deployment and architectural issues experienced in both previous iterations. It delivered a scalable, cost-effective, and production-grade system built fully on AWS-native services. With this structure in place, the project is now prepared to support authentication, monitoring, and future extensibility.

[Return to Project Overview](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/README.md)

---