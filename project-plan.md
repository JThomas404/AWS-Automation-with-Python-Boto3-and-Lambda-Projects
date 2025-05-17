# Phase 1: Infrastructure Setup Documentation

This document covers all technical steps completed during Phase 1 of the Serverless Web Application Project for ConnectingTheDots Corporation. The phase focused on establishing foundational infrastructure using Terraform and AWS best practices.

---

## Objectives

- Define Infrastructure as Code using Terraform
- Create an S3 bucket to host the static frontend
- Configure secure public access policies for static website hosting
- Establish a backend for Terraform state management
- Create IAM roles and permissions for Lambda functions

---

## Components Created

### 1. Terraform Backend Configuration
- A local backend was configured to manage state using a `terraform.tfstate` file.
- This can later be migrated to S3 + DynamoDB for remote team-based workflows.

```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

---

### 2. Random ID Generator
- Used to create a unique suffix for the S3 bucket name.

```hcl
resource "random_id" "ctd-random-number" {
  byte_length = 8
}
```

---

### 3. S3 Bucket Setup
- A uniquely named S3 bucket was created to host the static frontend site.

```hcl
resource "aws_s3_bucket" "ctd-s3-bucket" {
  bucket = "ctd-frontend-${random_id.ctd-random-number.hex}"
  tags = {
    Name = "ctd-s3-bucket"
    Environment = "terraform-programmatic-user"
  }
}
```

---

### 4. Public Access Configuration
- Disabled all default S3 bucket public access blocks to allow custom public policies.

```hcl
resource "aws_s3_bucket_public_access_block" "public-access" {
  bucket = aws_s3_bucket.ctd-s3-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```

---

### 5. S3 Bucket Policy for Public Read Access
- A bucket policy was attached to allow public `s3:GetObject` access to all objects.

```hcl
data "aws_iam_policy_document" "allow-public-access-on-bucket" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.ctd-s3-bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.ctd-s3-bucket.id
  policy = data.aws_iam_policy_document.allow-public-access-on-bucket.json
}
```

---

### 6. Static Website Hosting Configuration
- The bucket was configured to serve static files as a website.

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

---

### 7. IAM Role for Lambda Execution
- A custom IAM role was created that allows AWS Lambda to assume the role.

```hcl
resource "aws_iam_role" "ctd-lambda" {
  name = "ctd-lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = "ctd-lambda-execution-role"
  }
}
```

---

### 8. Policy Attachment for Lambda Logging
- The AWS-managed `AWSLambdaBasicExecutionRole` policy was attached.

```hcl
resource "aws_iam_role_policy_attachment" "ctd-lambda-execution-role-policy" {
  role       = aws_iam_role.ctd-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
```

---

## Files Involved

- `main.tf`: Infrastructure definitions
- `variables.tf`: Input variables (e.g., region)
- `outputs.tf`: Outputs for later referencing
- `.terraform.tfstate`: Terraform local state file (not version-controlled)

---

## Variable Definitions

```hcl
variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
```

(Additional variables may be added in the future for naming prefixes, tagging, etc.)

---

## Naming Conventions

- All resources, tags, and identifiers use hyphenated-case (e.g., `ctd-s3-bucket`) for consistency with AWS and Terraform naming practices.

---

## Permissions Notes

- Public read access (`s3:GetObject`) was deliberately enabled for the S3 bucket to allow website hosting.
- Lambda logging permissions were granted using the AWS-managed policy `AWSLambdaBasicExecutionRole`.

---

## Environment Setup

- Python environment is managed using a virtual environment (`.venv`)
- Terraform CLI version used: ensure `terraform --version` is >= 1.0.0

---

## Phase 1 Outcome

By the end of Phase 1, the foundational AWS infrastructure was deployed, including a publicly accessible S3 website bucket, a backend state management plan, and a secure Lambda execution IAM role.

---

# Phase 2: Backend API with Flask

## Objective
Build and deploy a Flask-based backend API to AWS Lambda using a serverless architecture. The API supports HTTP requests and is connected via API Gateway. The backend is packaged and deployed using Terraform and tested with Postman.

## Tasks Completed

### 1. Flask API Creation
- Created `app.py` with a basic Flask app using the Flask microframework
- Defined a simple route (`@app.route("/")`) returning a JSON response
- Added an additional route `/ping` for basic health checking
- Integrated Mangum to wrap the Flask application and adapt it to AWS Lambda's event-driven architecture
- Note: The Python backend logic will be expanded in later phases to support the full functionality of the web application

**`app.py` Code (Initial Version):**
```python
from flask import Flask, jsonify
from mangum import Mangum

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({"message": "Welcome to ConnectingTheDots!"})

@app.route("/ping")
def ping():
    return jsonify({"status": "alive"})

handler = Mangum(app)
```

### 2. Lambda Packaging
- Created a Python virtual environment `.venv` to manage dependencies in isolation
- Installed required packages (`Flask`, `Mangum`) using `pip`
- Compressed `app.py` and the `.venv` dependencies into a deployment package `lambda_function.zip` using best practices

### 3. IAM Role for Lambda
- Defined `aws_iam_role` with a trust relationship allowing Lambda to assume the role
- Attached the `AWSLambdaBasicExecutionRole` managed policy using `aws_iam_role_policy_attachment`
- Followed principle of least privilege to ensure safe and minimal access

### 4. Lambda Function Deployment
- Created the `aws_lambda_function` resource with the appropriate `handler`, `runtime`, and `filename`
- Used `filebase64sha256` to hash the deployment package and detect changes
- Configured the Lambda function name and tags using Terraform variables

### 5. API Gateway Configuration
- Created an HTTP API using `aws_apigatewayv2_api`
- Integrated the Lambda function using `aws_apigatewayv2_integration` with `AWS_PROXY` type
- Routed incoming HTTP requests using `aws_apigatewayv2_route` with `route_key = "ANY /"`
- Deployed a default stage using `aws_apigatewayv2_stage` with `auto_deploy = true`

### 6. Supporting Infrastructure
- Provisioned a uniquely named S3 bucket using `aws_s3_bucket` and `random_id`
- Allowed public read access with a custom `aws_s3_bucket_policy`
- Enabled static website hosting using `aws_s3_bucket_website_configuration`
- Set up public access rules using `aws_s3_bucket_public_access_block`

**Key Terraform Code Snippets:**
```hcl
provider "aws" {
  region = var.region
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "aws_s3_bucket" "ctd-s3-bucket" {
  bucket = "ctd-frontend-${random_id.ctd-random-number.hex}"
  tags = {
    Name        = "ctd-s3-bucket"
    Environment = "terraform-programmatic-user"
  }
}

resource "aws_iam_role" "ctd-lambda" {
  name = "ctd-lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  tags = {
    Name = "ctd-lambda-execution-role"
  }
}

resource "aws_lambda_function" "ctd-api" {
  filename         = "lambda_function.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.ctd-lambda.arn
  handler          = "app.handler"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256("lambda_function.zip")
  tags = {
    Name = var.project_tag
  }
}
```

### 7. Output and Testing
- Added an `output` block to retrieve the API Gateway endpoint after applying the Terraform plan
- Deployed the infrastructure and validated that the API responded correctly via:
  - Browser request
  - Postman HTTP request using the deployed API URL

**Postman Test Result:**
![Postman Test Result](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/postman.png)

### Challenges and Learnings
- Learned to configure `jsonencode` properly for IAM trust policies
- Discovered the importance of using `invoke_arn` instead of `arn` for Lambda integrations
- Understood how to use `ANY /` routes to handle all incoming HTTP methods via a single Lambda function
- Gained confidence working with API Gateway's layered architecture: API, Integration, Route, Stage
- Gained practical experience packaging Python apps for serverless deployment
- Practiced secure S3 hosting and public access control with Terraform

---

# Phase 3: Static Frontend with HTML, CSS, and JavaScript

## Objective

Deploy a static, styled frontend to the S3 bucket created in Phase 1. The interface serves as the user-facing layer of the application, allowing users to interact with sustainability training content and view responses from backend API endpoints. Although backend functionality is still evolving, this phase prepares the groundwork for full integration.

---

## Tasks Completed

### 1. HTML Frontend Design

**File**: `index.html`

- Created a basic HTML page that displays:
  - A welcome header
  - Introductory text about ConnectingTheDots Corporation
  - A container for displaying the API health status
  - A container for displaying future API data
- Integrated JavaScript logic within the HTML to:
  - Call the `/ping` endpoint for API health
  - Prepare a placeholder to fetch data from `/api/data` (to be added in a future phase)

**JavaScript Functions Included:**

- `checkAPIHealth()` – Fetches from the `/ping` API route and updates the UI with the status.
- `fetchData()` – Attempts to fetch resource data from `/api/data` and renders it as preformatted JSON.

These functions are called on page load to provide instant feedback on backend connectivity.

**Note**: The `/api/data` endpoint is not yet available, so the page gracefully handles the error.

---

### 2. Custom Error Page

**File**: `error.html`

- Provides a user-friendly error screen for cases such as:
  - 404 Not Found
  - Incorrect URL
- Includes a clear message and a button to return to the home page

This is set in the S3 bucket’s website configuration as the fallback page for invalid paths.

---

### 3. CSS Styling

**File**: `style.css`

- Centralised all styling in a separate CSS file for better maintainability and consistency
- Included layout rules for:
  - Main headings and paragraphs
  - Error page containers
  - Buttons and hover effects
- Responsive design and spacing were included for readability on various devices

**Example Styles:**
```css
.error-container {
  margin-top: 50px;
  text-align: center;
  padding: 40px;
}

.error-link {
  background: #0073e6;
  color: #fff;
  border-radius: 4px;
  padding: 10px 20px;
}
```

---

### 4. Static Hosting on S3

Used the Terraform-defined S3 bucket with static website hosting enabled during Phase 1.

#### Commands Run to Upload Files:

```bash
aws s3 cp ../frontend/index.html s3://ctd-frontend-54cdbaf48772c3c3/
aws s3 cp ../frontend/error.html s3://ctd-frontend-54cdbaf48772c3c3/
aws s3 cp ../frontend/style.css s3://ctd-frontend-54cdbaf48772c3c3/
```

These files are now hosted and publicly accessible via the configured S3 bucket.

---

### 5. Validation and Testing

#### Website URL:
`http://ctd-frontend-54cdbaf48772c3c3.s3-website-us-east-1.amazonaws.com`

- Verified:
  - Page loads successfully
  - `/ping` check reflects backend status correctly
  - Error fallback works when navigating to an undefined route

---

## Screenshots

### Home Page

![Frontend](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/frontend.png)

---

### Error Page

![Error Page](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/error-page.png)

---
# Phase 4 – Flask API Deployment & DynamoDB Integration

This phase covers the backend API implementation using Flask, integrated with DynamoDB, and deployed to AWS Lambda through Terraform. The process included packaging Python dependencies, deploying infrastructure, and verifying API responses. Issues encountered during deployment and troubleshooting are documented separately in [`challenges-and-learnings.md`](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/docs/challenges-and-learnings.md).

---

## Summary of Tasks

### 1. Created Flask API (`app.py`)
- Defined basic API routes:
  - `/` – returns a welcome message.
  - `/ping` – simple health check.
  - `/api/data` – connects to DynamoDB to fetch data.
- Wrapped Flask app with `Mangum(app)` for AWS Lambda compatibility (later replaced due to compatibility issues).

```python
from flask import Flask, jsonify
from mangum import Mangum
import boto3

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({"message": "Welcome to ConnectingTheDots!"})

@app.route("/ping")
def ping():
    return jsonify({"status": "alive"})

@app.route("/api/data")
def api():
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("ConnectingTheDotsDBTable")
    response = table.scan()
    return jsonify(response.get("Items", []))

handler = Mangum(app)
```

---

### 2. Provisioned DynamoDB Table
- Defined `ConnectingTheDotsDBTable` using Terraform:
  - Partition key: `UserId`
  - Billing mode: `PAY_PER_REQUEST`

```hcl
resource "aws_dynamodb_table" "ctd-db" {
  name         = "ConnectingTheDotsDBTable"
  hash_key     = "UserId"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "UserId"
    type = "S"
  }
}
```

---

### 3. Installed and Packaged Dependencies
- Created `.venv` and installed:
  - Flask
  - Boto3
  - Mangum (initially, later removed)
- Installed packages into a `package/` directory.
- Zipped `app.py` with `package/` to create `lambda_function.zip`.

```bash
pip install flask boto3 mangum -t package/
cp app.py package/
cd package && zip -r ../lambda_function.zip .
```

---

### 4. Deployed Lambda with Terraform
- Used `aws_lambda_function` resource to deploy the zip package.
- Defined IAM role with logging and DynamoDB access policies.
- Used `filebase64sha256()` to detect Lambda source changes.

```hcl
resource "aws_lambda_function" "ctd-api" {
  filename         = "lambda_function.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.ctd-lambda.arn
  handler          = "app.handler"
  runtime          = var.lambda_runtime
  timeout          = 10
  source_code_hash = filebase64sha256("lambda_function.zip")
}
```

---

### 5. Connected API Gateway to Lambda
- Configured:
  - API Gateway (HTTP type)
  - Lambda integration using `AWS_PROXY`
  - Route `ANY /{proxy+}` for dynamic routing
  - `$default` stage with CloudWatch logging

---

### 6. Validated API
- Deployed the full infrastructure.
- Called the deployed endpoint to verify:
  - `/` returned `{"message": "Welcome to ConnectingTheDots!"}`
  - `/ping` responded with alive status

---

### Outcome
A fully functional Flask API backed by DynamoDB and served through Lambda and API Gateway was deployed. This sets the groundwork for implementing full CRUD operations in upcoming steps.

---

# Phase 5 – Flask Frontend Integration

This section documents the full process of setting up a custom Flask-based frontend for the ConnectingTheDots web application. The goal of Phase 5 was to replace the static S3-based frontend with a dynamic, extensible interface built using Flask templates and static assets.

---

## Step 1: Set Up the Flask Frontend Folder Structure

A clean and scalable folder structure was implemented:

```
/your-project
├── app.py
├── templates/
│   ├── base.html
│   ├── home.html
│   ├── dashboard.html
│   └── contact.html
├── static/
│   └── css/
│       └── style.css
│   └── videos/
│       └── body-background.mp4
```

- `templates/`: Contains Jinja2 HTML templates for all pages
- `static/`: Hosts CSS, JavaScript, and video assets for styling and background
- `app.py`: Main Flask application that routes between pages and serves content

---

## Step 2: Add Navigation Logic and Basic Templates

Navigation was added to `base.html`, which all other pages inherit. A navigation bar allows users to switch between:

- Home (`/`)
- Dashboard (`/dashboard`)
- Contact (`/contact`)

Example snippet in `base.html`:

```html
<nav>
  <a href="{{ url_for('home') }}">Home</a> |
  <a href="{{ url_for('dashboard') }}">Dashboard</a> |
  <a href="{{ url_for('contact') }}">Contact</a>
</nav>
```

Each page (`home.html`, `dashboard.html`, `contact.html`) was created using:

```html
{% extends 'base.html' %}

{% block content %}
  <!-- Page-specific content -->
{% endblock %}
```

---

## Step 3: Test the Application Locally

The app was launched locally using Flask:

```bash
flask run --host=0.0.0.0
```

Accessed via browser at:

- http://127.0.0.1:5000
- http://192.168.x.x:5000 (for local network access)

All routes rendered successfully and navigation worked as expected.

---

## Step 4: Style the Frontend with the Brand

A custom `style.css` was added based on the company's branding. Key features:

- Font: Inter for modern readability
- Background: Full-screen looping video (stored in `static/videos/`)
- Colour scheme: Dark theme with CTD brand colours (navy and gold highlights)
- Layout: Responsive, modern design with frosted glass effect

Additional enhancements:

- Scroll to top button
- Responsive nav bar with branding logo (`CTDC.png`)
- Fixed navigation and transition smoothing

```css
nav a {
  font-size: 1.1rem;
  color: #fff;
  text-decoration: none;
  margin: 0 15px;
}

#background-video {
  position: fixed;
  top: 0;
  left: 0;
  min-width: 100vw;
  min-height: 100vh;
  object-fit: cover;
  z-index: -2;
}
```

---

## Outcome of Phase 5

By the end of this phase:

- A responsive and branded Flask-based frontend was fully implemented.
- All routes render the correct content dynamically.
- Visual identity matches the ConnectingTheDots corporate branding.
- Background video plays smoothly with overlay and readable content.
- Structure is scalable for adding authentication, user-specific data, and contact logic in future phases.

---

# Phase 6: Flask Frontend Integration with Contact Form Submission

Phase 6 focused on developing a fully functional frontend for the ConnectingTheDots serverless application using Flask. It included designing a responsive website, implementing navigation, embedding a background video, and building a contact form that integrates directly with AWS DynamoDB. This phase marked the shift from static content to dynamic interaction and serverless data handling.

---

## Objectives

- Build a dynamic, styled frontend using Flask and Jinja templates
- Create dedicated pages for Home, Dashboard, and Contact
- Design and validate a professional contact form with required fields
- Handle form submission server-side using a Flask POST route
- Store submitted data in a DynamoDB table via AWS Lambda
- Ensure secure infrastructure with appropriate IAM permissions

---

## Tasks Completed

### 1. Flask Frontend Structure and Templates
- Built a directory layout using:
  ```
  /templates
    ├── base.html
    ├── home.html
    ├── dashboard.html
    └── contact.html
  /static/css
    └── style.css
  /static/videos
    └── body-background.mp4
  /static/images
    └── CTDC.png
  ```
- `base.html` served as the root template with a reusable navigation bar and layout block.
- Added navigation links and a background video across all pages using HTML5 `<video>`.
- Applied a blurred glass effect to the main content area using `backdrop-filter`.

### 2. Navigation and Styling Enhancements
- Navigation was aligned beside the logo (top left)
- Included hover effects and colour scheme matching the company brand
- Enabled dark mode using `<meta name="color-scheme" content="dark">`
- Embedded a fixed-position scroll-to-top button
- Font improved using `Inter` for better legibility
- Responsive structure ensured for all screen sizes

### 3. Contact Page and Form Implementation
- Created a contact form under `contact.html`
- Structured into two columns using CSS flexbox
- Fields included:
  - First Name (required)
  - Last Name (required)
  - Job Title
  - Phone Number
  - Company
  - Email Address (required & used as the DynamoDB partition key)
- Form includes real-time browser validation (`required` attributes)

### 4. Form Backend Logic in Flask
- A `/submit_contact` route was added to receive POST requests
- Used `request.form.get()` to retrieve data
- Basic validation added server-side to catch missing required fields
- Connected to DynamoDB using Boto3 and inserted a new item
- Redirected back to the contact page upon successful submission

**Key Flask Route:**
```python
@app.route("/submit_contact", methods=["POST"])
def submit_contact():
    # Validates form input
    # Stores data in DynamoDB using boto3
    # Redirects back to /contact or returns error if failed
```

### 5. DynamoDB Table for Contact Form Storage
- Updated Terraform to include a new DynamoDB table:
  ```hcl
  resource "aws_dynamodb_table" "ctd-db" {
    name         = "ConnectingTheDotsDBTable"
    hash_key     = "email"
    billing_mode = "PAY_PER_REQUEST"

    attribute {
      name = "email"
      type = "S"
    }
  }
  ```
- Partition key set to `email` to ensure unique contact entries

### 6. IAM Role and Policy Updates
- Lambda role updated to use `AmazonDynamoDBFullAccess` to allow writes to the table

**Terraform IAM Role Attachment:**
```hcl
resource "aws_iam_role_policy_attachment" "ctd-dynamodb-write" {
  role       = aws_iam_role.ctd-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
```

### 7. Form Submission and Data Verification
- Submitted test data through the frontend form
- Confirmed that items were saved correctly in DynamoDB
- Used AWS Console to verify stored items

**Screenshots for Documentation:**
- ![Form Submitted](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/contact-form-message.png)
- ![Saved Data 1](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/form-items-saved-1.png)
- ![Saved Data 2](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/form-items-saved-2.png)

---

## Outcome

By the end of Phase 6:
- A visually compelling, responsive frontend was created using Flask and CSS
- Users can now browse company details and services via a clean UI
- Form submissions are stored in DynamoDB via Lambda, with both client-side and server-side validation
- All infrastructure remains serverless and scalable

This phase sets the foundation for future features such as user authentication, admin dashboards, or email automation.

---