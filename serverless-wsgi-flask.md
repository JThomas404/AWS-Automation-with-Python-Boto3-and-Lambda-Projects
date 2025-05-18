# Phase 2 – Serverless Flask with WSGI and Boto3

## Project Summary

This phase marked the first attempt to transition the application from a local prototype to a remotely accessible, serverless architecture. Rather than rewriting the entire application from scratch, I chose to retain the Flask backend and integrate it with AWS Lambda using the Serverless Framework and the `serverless-wsgi` plugin.

This approach allowed me to deploy the existing application while beginning to work with managed services such as API Gateway and Lambda. However, the method ultimately proved unstable, unscalable, and unnecessarily complex to maintain.

---

## Overview

The primary goal of this phase was to make the existing Flask application deployable and accessible via the web without requiring local execution. The application logic remained the same:

- Accept contact form submissions via HTML
- Process the data with Flask
- Store the submissions in DynamoDB using Boto3

Instead of running on `localhost`, the application would now execute as a Lambda function, with API Gateway handling HTTP routing.

---

## Tech Stack

| Category        | Technology                         |
|----------------|-------------------------------------|
| Framework       | Python Flask                       |
| Infrastructure  | AWS Lambda                         |
| API Routing     | AWS API Gateway                    |
| SDK             | Boto3 (AWS SDK for Python)         |
| Packaging Tool  | Serverless Framework + WSGI Plugin |
| Deployment      | serverless.yml configuration       |
| Database        | AWS DynamoDB                       |
| Runtime         | Python 3.8                         |

---

## Folder Structure

```

second-attempt-s3-web-app/
├── backend/
│   ├── __pycache__/
│   │   └── app.cpython-313.pyc
│   ├── .serverless/
│   │   └── meta.json
│   ├── .venv/
│   ├── node.modules/
│   ├── .serverless-wsgi.txt
│   ├── app.py
│   ├── package-lock.json
│   ├── package.json
│   ├── requirements.txt
│   ├── serverless_wsgi.py
│   ├── serverless.yml
│   └── wsgi_handler.py

├── frontend/
│   ├── images/
│   │   └── CTDC.png
│   ├── base.html
│   ├── contact.html
│   ├── dashboard.html
│   ├── index.html
│   └── style.css

├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf

````

---

## Setup and Deployment

1. Set up the Python environment and install dependencies:

```bash
python3 -m venv venv
source venv/bin/activate
pip install flask boto3 serverless serverless-wsgi
pip freeze > requirements.txt
````

2. Deploy to AWS using the Serverless CLI:

```bash
sls deploy
```

3. After deployment, API Gateway returns an endpoint. Example:

```
https://<api-id>.execute-api.<region>.amazonaws.com/dev/contact
```

4. Frontend form submissions post directly to this endpoint.

---

## Validation and Testing

To confirm the backend worked as expected, I tested POST requests using both Postman and cURL. These allowed me to validate API Gateway, Lambda, and DynamoDB interactions.

### Postman Test

POST request with `application/x-www-form-urlencoded`:

* **Name**: Jarred
* **Email**: [jarred@example.com](mailto:jarred@example.com)
* **Message**: Testing Flask WSGI setup

**Result**:

* Status Code: `200 OK`
* Body: `Submission successful`

![Successful Postman](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/successful-curl.png)

---

### cURL Test

```bash
curl -X POST https://<api-id>.execute-api.us-east-1.amazonaws.com/dev/contact \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "name=Jarred&email=jarred@example.com&message=From cURL"
```

![Welcome Message Screenshot](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/welcome-message.png)

---

## Significant Configuration Snippets

### serverless.yml

```yaml
service: serverless-flask-api

provider:
  name: aws
  runtime: python3.8
  region: us-east-1

plugins:
  - serverless-wsgi
  - serverless-python-requirements

custom:
  wsgi:
    app: app.app
    packRequirements: false

functions:
  app:
    handler: wsgi_handler.handler
    events:
      - http: ANY /
      - http: 'ANY {proxy+}'
```

### wsgi\_handler.py

```python
from wsgi import handler
```

---

## Observations and Issues

| Issue                       | Description                                                               |
| --------------------------- | ------------------------------------------------------------------------- |
| WSGI abstraction complexity | Obscured errors and made Lambda debugging tedious                         |
| Persistent CORS issues      | Required manual header injection; OPTIONS handling was inconsistent       |
| Packaging overhead          | Deployments were large due to dependency bundling and zipped environments |
| Fragile error handling      | CloudWatch logs lacked clarity, hiding stack traces behind WSGI           |
| Inefficient deployment loop | Required frequent repackaging and redeployments for small changes         |

---

## Lessons and Takeaways

**Demonstrated End-to-End Serverless Deployment**
This was my first successful deployment of a Python Flask app using Lambda and API Gateway. It validated my knowledge of request routing, payload handling, and serverless packaging.

**Exposed the Incompatibility Between WSGI and Lambda**
The complexity introduced by adapting Flask with WSGI ultimately hindered visibility and maintainability. Errors were deeply buried, and stack traces were obscured.

**Reinforced the Importance of CORS and Gateway Design**
I learned that CORS is not just a frontend concern. It must be explicitly handled in both the Lambda response and API Gateway integration/method response configuration.

**Identified the Need for AWS-Native Architecture**
Trying to make Flask serverless worked in theory, but not in practice. Native tools like Python-based Lambda functions, S3, and API Gateway offer better alignment with serverless paradigms.

**Informed the Decision to Rebuild Simpler**
This phase taught me that simplicity and native tooling often outperform adaptation. In the next phase, I removed Flask entirely and adopted a clean separation of frontend and backend using S3 and Lambda.

---

## Transition to Next Phase

Although this phase achieved a working deployment, it was fragile and difficult to iterate on. These limitations drove the design of a more robust solution using AWS-native services for hosting, routing, and compute.

[Continue to Phase 3 → Static Site (S3 + Lambda + API Gateway)](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/final-phase-s3-web-app.md)

---