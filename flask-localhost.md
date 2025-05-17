# Phase 1 – Flask (Localhost Prototype)

## Project Summary

This phase served as the initial prototype of the application. Its primary purpose was to establish the core functionality: capturing user input through a web form and storing it in AWS DynamoDB using Python Flask and Boto3. While limited in scalability and deployment scope, this phase was instrumental in laying the technical foundation for subsequent iterations.

Development and testing were performed entirely on `localhost`, with no remote deployment.

---

## Overview

The goal of this phase was to validate a basic full-stack workflow:

- Build a static HTML contact form
- Capture form submissions via a Flask backend
- Store the submitted data in a DynamoDB table using Boto3

While the application functioned as expected, the architecture revealed several fundamental limitations — particularly its reliance on a continuously running local server, absence of hosting, and lack of scalability or fault tolerance.

---

## Tech Stack

| Category        | Technology                 |
|----------------|-----------------------------|
| Backend         | Python (Flask)             |
| Database        | AWS DynamoDB               |
| SDK             | Boto3 (AWS SDK for Python) |
| Frontend        | HTML and CSS               |
| Dev Environment | Python venv                |
| Hosting         | None (localhost only)      |

---

## Folder Structure

```

first-attempt-flask-web-app/
├── backend/
│   ├── app.py
│   ├── lambda_function.zip
│   ├── pre-signup.py
│   ├── pre-signup.zip
│   ├── requirements.txt
│   └── scan_dynamodb.py

├── frontend/
│   ├── base.html
│   ├── contact.html
│   ├── dashboard.html
│   ├── error.html
│   ├── home.html
│   ├── index.html
│   └── style.css

├── terraform/
│   ├── .terraform.lock.hcl
│   ├── lambda_function.zip
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   └── variables.tf

````

---

## Setup and Installation

1. Create and activate a Python virtual environment:

```bash
python3 -m venv venv
source venv/bin/activate
````

2. Install project dependencies:

```bash
pip install flask boto3
pip freeze > requirements.txt
```

3. Run the application:

```bash
python app.py
```

4. Access the form at:

```
http://localhost:5000
```

---

## `app.py` — Core Flask Application Logic

```python
from flask import Flask, render_template, request
import boto3

app = Flask(__name__)

# AWS DynamoDB configuration
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('contact-submissions')

@app.route('/', methods=['GET', 'POST'])
def contact():
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        message = request.form.get('message')

        # Store in DynamoDB
        table.put_item(Item={
            'email': email,
            'name': name,
            'message': message
        })

        return "Submission successful"
    return render_template('contact.html')

if __name__ == '__main__':
    app.run(debug=True)
```

---

## `templates/contact.html` — Contact Form

```html
<form action="/" method="POST">
  <input type="text" name="name" placeholder="Your Name" required />
  <input type="email" name="email" placeholder="Your Email" required />
  <textarea name="message" placeholder="Your Message" required></textarea>
  <button type="submit">Submit</button>
</form>
```

---

## Successful Contact Page

![Contact Us](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/raw/main/images/contact-form-message.png)

---

## Testing and Validation

* The Flask server was run locally at `localhost:5000`
* Manual submissions were used to test the form and validate backend handling
* Form entries were confirmed in the AWS DynamoDB console
* Debugging was performed using `print()` statements and Flask’s development server

![Form Items Saved 1](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/raw/main/images/form-items-saved-1.png)
![Form Items Saved 2](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/raw/main/images/form-items-saved-2.png)

---

## Limitations

| Constraint                            | Impact                                               |
| ------------------------------------- | ---------------------------------------------------- |
| Flask server required local execution | Application was unavailable unless manually started  |
| No deployment pipeline                | App was inaccessible outside the development machine |
| AWS credentials managed manually      | No secrets management or environment isolation       |
| No fault tolerance or scaling         | No resilience or availability guarantees             |

---

## Lessons and Takeaways

* **Established Functional Workflow**
  Confirmed the complete pipeline from frontend input to backend processing and database persistence. This validated my understanding of HTTP request handling, templating, and form logic in Flask.

* **Hands-On Use of Boto3 and DynamoDB**
  Gained practical experience using the Boto3 SDK for interacting with DynamoDB, including resource configuration and basic CRUD operations.

* **Understood the Boundaries of Local-Only Applications**
  Realised that an application running only on `localhost` is inherently constrained and unfit for production environments.

* **Identified the Need for Remote Hosting and Stateless Design**
  This project demonstrated the need to separate application logic from the developer's environment, and to pursue serverless, event-driven infrastructure.

* **Informed Strategic Decisions for Phase 2**
  These limitations shaped the architecture of the next phase — motivating a shift toward API Gateway, Lambda, and eventual Terraform-managed deployments.

---

## Transition to Next Phase

While Phase 1 validated core functionality, it fell short of being scalable, secure, or remotely deployable. These shortcomings ultimately led to Phase 2 — where the Flask app would be restructured and deployed to AWS Lambda using the Serverless Framework.

[Continue to Phase 2 → Serverless Flask with WSGI](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/serverless-wsgi-flask.md)

---