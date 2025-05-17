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

| Category        | Technology             |
|----------------|-------------------------|
| Backend         | Python (Flask)         |
| Database        | AWS DynamoDB           |
| SDK             | Boto3 (AWS SDK for Python) |
| Frontend        | HTML and CSS           |
| Dev Environment | Python venv            |
| Hosting         | None (localhost only)  |

---

## Folder Structure

```

flask-localhost/
├── app.py                  # Flask backend application
├── requirements.txt        # Python dependencies
├── templates/
│   └── contact.html        # Contact form
├── static/
│   └── style.css           # Styling (optional)
└── venv/                   # Virtual environment (excluded from Git)

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

4. Access the form by navigating to:

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

## Testing and Validation

* The Flask server was executed locally on `localhost:5000`
* Manual form submissions were used to validate input handling
* Submissions were verified in the DynamoDB console
* Debugging was performed using `print()` statements and Flask's development server

---

## Limitations

| Constraint                            | Impact                                                        |
| ------------------------------------- | ------------------------------------------------------------- |
| Flask server required local execution | Application unavailable unless manually started               |
| No deployment pipeline                | Application was inaccessible to users outside the dev machine |
| AWS credentials managed manually      | No secrets management or environment separation               |
| No fault tolerance or scaling         | Application had no resilience or availability guarantees      |

---

## Lessons and Takeaways

* **Established Functional Workflow**
  Implemented and validated a basic application pipeline from frontend form submission to backend processing and database storage. This confirmed my understanding of HTTP request handling, template rendering, and form parsing in Flask.

* **Hands-On Use of Boto3 and DynamoDB**
  Gained practical experience with AWS Boto3 SDK, including resource initialisation, environment configuration, and interacting with DynamoDB tables using `put_item()`. Also learned about DynamoDB's schema-less nature and importance of designing a suitable partition key.

* **Understood the Boundaries of Local-Only Applications**
  Recognised that an application tied to a local server is inherently limited. There was no scalability, no reliability, and no accessibility beyond the development machine. This constraint rendered the architecture unsuitable for production use.

* **Identified the Need for Remote Hosting and Stateless Design**
  This experience highlighted the necessity of decoupling the application from local infrastructure. It became clear that the next phase would require a serverless, cloud-native approach using AWS Lambda and API Gateway to allow the application to run independently of my machine.

* **Informed Strategic Decisions for Phase 2**
  This phase clarified what needed to change going forward — namely, moving toward event-driven architecture, managed infrastructure, and deployment automation. The limitations observed here directly influenced the design of the second iteration.

---

## Transition to Next Phase

While Phase 1 demonstrated working functionality, it fell short in terms of deployability, accessibility, and cloud readiness. These shortcomings drove the transition to a serverless model using Lambda, API Gateway, and the Serverless Framework.

[Continue to Phase 2 → Serverless Flask with WSGI](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/serverless-wsgi-flask.md)

```

---
