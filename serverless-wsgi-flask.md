# Phase 2 – Serverless Flask with WSGI and Boto3

## Project Summary

This phase was the first attempt at transitioning the application from a local prototype to a remotely accessible, serverless architecture. Rather than rewriting the entire application from scratch, I opted to retain the Flask backend and integrate it into AWS Lambda using the Serverless Framework and the `serverless-wsgi` plugin.

This approach allowed me to deploy the existing application while beginning to work with managed infrastructure such as API Gateway and Lambda. However, the method ultimately proved unstable, unscalable, and unnecessarily complex to maintain.

---

## Overview

The primary goal of this phase was to make the existing Flask application deployable and accessible via the web without running locally. The application flow remained the same:

- Accept contact form submissions via HTML
- Process the form using Flask
- Store the data in DynamoDB using Boto3

However, instead of executing on `localhost`, the application would now be hosted as a Lambda function, with API Gateway handling HTTP routing.

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

serverless-wsgi-flask/
├── app.py                    # Flask application
├── requirements.txt          # Python dependencies
├── serverless.yml            # Serverless Framework config
├── wsgi\_handler.py           # WSGI handler adapter
├── templates/
│   └── contact.html
├── static/
│   └── style.css
└── venv/                     # Local virtual environment (excluded from Git)

````

---

## Setup and Deployment

1. Install project dependencies into a virtual environment:

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

3. After deployment, API Gateway will return an endpoint. Example:

```
https://<api-id>.execute-api.<region>.amazonaws.com/dev/contact
```

4. Frontend form submissions would post directly to this endpoint.

---

## Validation and Testing

To confirm that the Lambda function was correctly wired to DynamoDB via API Gateway, I tested POST requests using both **Postman** and **cURL**. The following tools allowed me to validate backend logic without relying on the frontend.

### Postman Test

POST request to `/contact` with form-urlencoded data:

* Name: Jarred
* Email: [jarred@example.com](mailto:jarred@example.com)
* Message: Testing Flask WSGI setup

**Result:**

* Status Code: 200
* Response: `Submission successful`

![Postman Screenshot](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/postman.png)

---

### cURL Test

```bash
curl -X POST https://<api-id>.execute-api.us-east-1.amazonaws.com/dev/contact \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "name=Jarred&email=jarred@example.com&message=From cURL"
```

**Result:**
200 OK with confirmation that the data was written to DynamoDB.

![Successful cURL](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/successful-curl.png)

---

### Lambda Welcome Message

For GET requests or default route testing, the Lambda returned a simple welcome response to confirm routing was operational.

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

| Problem                     | Description                                                                   |
| --------------------------- | ----------------------------------------------------------------------------- |
| WSGI abstraction complexity | Errors were obscured by WSGI, making debugging Lambda logs time-consuming.    |
| CORS issues persisted       | Preflight requests often failed. Manual header injection became unreliable.   |
| Packaging overhead          | The zipped deployment became large and unstable due to dependency management. |
| Fragile error handling      | Lambda error traces were buried or unhelpful in CloudWatch logs.              |
| Inefficient workflow        | Every change required a repackage and redeploy cycle, slowing iteration.      |

---

## Lessons and Takeaways

**Demonstrated End-to-End Serverless Deployment**
Successfully deployed a functioning Flask application on AWS Lambda using API Gateway and the Serverless Framework. This confirmed my understanding of request routing, WSGI adaptation, and packaging Python workloads for Lambda.

**Exposed the Incompatibility Between WSGI and Lambda**
While WSGI offers portability, its interaction with Lambda introduced a layer of indirection that made debugging and observability difficult. Lambda errors were often obscured by WSGI stack traces, making root-cause identification slow and imprecise.

**Reinforced the Importance of Clean API Design and CORS Management**
This phase highlighted how essential it is to properly structure API Gateway resources and define consistent CORS headers across both preflight and actual responses.

**Identified the Need for AWS-Native Architecture**
Retrofitting a Flask application into Lambda worked in theory but proved cumbersome in practice. It became clear that moving forward, the solution needed to be designed natively for AWS services — rather than adapting monolithic frameworks.

**Informed the Decision to Simplify the Stack Entirely**
The cumulative issues with WSGI, Flask, and dependency management drove the decision to eliminate the Flask layer altogether. The next phase would instead separate the frontend and backend, use static S3 hosting for the UI, and a pure Python Lambda function for data handling.

---

## Transition to Next Phase

Although this phase delivered a deployed application, it became increasingly unstable and impractical to maintain. These architectural limitations led to a cleaner, AWS-native redesign in the next iteration — built around S3, CloudFront, API Gateway, and standalone Lambda functions without the WSGI or Flask layers.

[Continue to Phase 3 → Static Site (S3 + Lambda + API Gateway)](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/final-phase-s3-web-app.md)

---