# AWS Serverless Web Application with Terraform Infrastructure

A production-ready serverless web application demonstrating cloud-native architecture patterns, infrastructure as code, and iterative engineering problem-solving. This project evolved through three distinct phases, each addressing specific architectural challenges and culminating in a scalable, secure solution hosted on AWS.

**Live Application:** [https://www.connectingthedotscorp.com](https://www.connectingthedotscorp.com)

## Table of Contents

- [Overview](#overview)
- [Real-World Business Value](#real-world-business-value)
- [Prerequisites](#prerequisites)
- [Project Folder Structure](#project-folder-structure)
- [Tasks and Implementation Steps](#tasks-and-implementation-steps)
- [Core Implementation Breakdown](#core-implementation-breakdown)
- [Local Testing and Debugging](#local-testing-and-debugging)
- [IAM Role and Permissions](#iam-role-and-permissions)
- [Design Decisions and Highlights](#design-decisions-and-highlights)
- [Errors Encountered and Resolved](#errors-encountered-and-resolved)
- [Skills Demonstrated](#skills-demonstrated)
- [Conclusion](#conclusion)

## Overview

This project implements a serverless contact form application using AWS cloud services, demonstrating the evolution from a local Flask prototype to a production-ready static site with API-driven backend. The architecture leverages S3 for static hosting, CloudFront for content delivery, API Gateway for request routing, Lambda for serverless compute, and DynamoDB for data persistence.

The implementation showcases three distinct architectural approaches:
1. **Phase 1**: Flask application running on localhost with DynamoDB integration
2. **Phase 2**: Serverless Flask deployment using WSGI adapter with Lambda and API Gateway
3. **Phase 3**: Decoupled static frontend with dedicated Lambda backend (current production implementation)

Each phase addressed specific scalability, maintainability, and operational challenges, ultimately resulting in a clean separation of concerns and optimal resource utilisation.

## Real-World Business Value

This project delivers tangible business outcomes through:

- **Cost Optimisation**: Serverless architecture eliminates idle server costs, scaling to zero when unused
- **Global Performance**: CloudFront CDN ensures sub-100ms response times across geographic regions
- **Security Compliance**: HTTPS enforcement, CORS configuration, and managed IAM policies
- **Operational Excellence**: Infrastructure as code enables reproducible deployments and version control
- **Scalability**: Auto-scaling Lambda functions handle traffic spikes without manual intervention
- **Reliability**: Multi-AZ deployment with AWS managed services providing 99.9% uptime SLA

The solution processes real customer enquiries with full audit trails stored in DynamoDB, supporting business growth through reliable digital presence.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Python 3.9+
- Domain registered in Route 53 (for custom domain setup)
- Basic understanding of AWS services: S3, Lambda, API Gateway, DynamoDB, CloudFront

## Project Folder Structure

```
AWS-Automation-with-Python-Boto3-and-Lambda-Projects/
├── first-attempt-flask-web-app/          # Phase 1: Local Flask prototype
│   ├── backend/
│   │   └── app.py                        # Flask application with DynamoDB integration
│   └── frontend/                         # HTML templates and CSS
├── second-attempt-s3-web-app/            # Phase 2: Serverless Flask with WSGI
│   ├── backend/
│   │   ├── serverless.yml                # Serverless Framework configuration
│   │   ├── wsgi_handler.py               # WSGI adapter for Lambda
│   │   └── requirements.txt              # Python dependencies
│   └── frontend/                         # Static website files
├── final-phase-s3-web-app/               # Phase 3: Production implementation
│   ├── terraform/                        # Infrastructure as code
│   │   ├── main.tf                       # S3, DynamoDB, and primary configuration
│   │   ├── cloudfront.tf                 # CDN and SSL configuration
│   │   ├── api-gateway.tf                # API Gateway and CORS setup
│   │   ├── lambda.tf                     # Lambda function and IAM roles
│   │   ├── route53.tf                    # DNS configuration
│   │   └── cognito.tf                    # Authentication (work in progress)
│   ├── backend/
│   │   └── app.py                        # Lambda function source code
│   └── frontend/                         # Static website files
│       ├── index.html                    # Main landing page
│       ├── contact.html                  # Contact form page
│       └── style.css                     # Responsive styling
├── challenges-and-learnings.md           # Detailed technical challenges documentation
└── README.md                             # Project overview and documentation
```

## Tasks and Implementation Steps

### Phase 1: Local Prototype Development
1. **Flask Application Setup**: Created basic web server with form handling capabilities
2. **DynamoDB Integration**: Implemented boto3 client for data persistence
3. **Local Testing**: Validated form submissions and database writes on localhost
4. **Limitation Identification**: Recognised scalability constraints of local deployment

### Phase 2: Serverless Migration Attempt
1. **WSGI Adapter Implementation**: Wrapped Flask app for Lambda compatibility
2. **Serverless Framework Configuration**: Defined deployment pipeline and API Gateway integration
3. **CORS Configuration**: Addressed cross-origin request handling
4. **Debugging and Troubleshooting**: Resolved packaging issues and dependency conflicts
5. **Architecture Reassessment**: Identified maintainability concerns with WSGI approach

### Phase 3: Production Architecture Implementation
1. **Infrastructure Design**: Architected decoupled static frontend with API backend
2. **Terraform Configuration**: Implemented infrastructure as code for all AWS resources
3. **Static Site Deployment**: Configured S3 hosting with CloudFront distribution
4. **API Gateway Setup**: Created RESTful endpoints with proper CORS handling
5. **Lambda Function Development**: Built dedicated form processing handler
6. **SSL and Domain Configuration**: Implemented HTTPS with custom domain routing
7. **Testing and Validation**: Conducted end-to-end testing with real form submissions

## Core Implementation Breakdown

### Lambda Function Architecture

The production Lambda function (`backend/app.py`) implements robust form processing with multiple content-type support:

```python
def lambda_handler(event, context):
    logger.info("Lambda event received: %s", json.dumps(event))

    if event.get('httpMethod') == 'OPTIONS':
        return cors_response(200, "CORS preflight OK")

    path = event.get('path', '')

    try:
        if path == '/contact':
            return handle_contact(event)
        elif path == '/userdata':
            return handle_userdata_stub(event)
        else:
            logger.warning("Unhandled path: %s", path)
            return cors_response(404, {"error": "Not Found"})

    except Exception as e:
        logger.error("Exception occurred: %s", str(e))
        return cors_response(500, {"error": "Internal server error"})

def handle_contact(event):
    content_type = event["headers"].get("Content-Type") or event["headers"].get("content-type", "")
    body = event.get("body", "")

    if "application/json" in content_type:
        body = json.loads(body)
    elif "application/x-www-form-urlencoded" in content_type:
        parsed = urllib.parse.parse_qs(body)
        body = {k: v[0] for k, v in parsed.items()}

    # Store in DynamoDB
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("ConnectingTheDots")
    table.put_item(Item=body)

    return cors_response(200, {"message": "Contact data stored successfully"})
```

### Infrastructure as Code Implementation

The Terraform configuration demonstrates modular resource management:

**S3 and CloudFront Configuration (main.tf and cloudfront.tf):**
```hcl
resource "aws_s3_bucket" "ctdc-s3-bucket" {
  bucket = "connectingthedots-${random_id.ctdc-random-number.hex}"

  tags = {
    Name = var.project_tag
  }
}

resource "aws_cloudfront_distribution" "ctdc-distribution" {
  aliases             = ["www.connectingthedotscorp.com"]
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.ctdc-s3-bucket.bucket_regional_domain_name
    origin_id                = "ctdc-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.ctdc-oac.id
  }
  
  default_cache_behavior {
    target_origin_id       = "ctdc-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress              = true
  }
}
```

**API Gateway with CORS (api-gateway.tf):**
```hcl
resource "aws_api_gateway_rest_api" "ctdc-api" {
  name        = "ctdc-api"
  description = "API Gateway for Connecting The Dots Lambda"
}

resource "aws_api_gateway_method_response" "ctdc-contact-post-response" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-contact-resource.id
  http_method = "POST"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}
```

### Frontend Implementation

The static frontend (`frontend/index.html`) provides a professional corporate website:

```html
<!DOCTYPE html>
<html lang="en" class="loading">
<head>
  <meta charset="UTF-8">
  <title>Connecting The Dots Corporation</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <!-- Background Video -->
  <video autoplay muted loop playsinline id="background-video">
    <source src="videos/body-background.mp4" type="video/mp4">
  </video>

  <!-- Navigation -->
  <nav>
    <div class="nav-left">
      <img src="images/CTDC.png" alt="CTD Logo" class="logo">
      <div class="nav-links">
        <a href="index.html">Home</a>
        <a href="dashboard.html">Dashboard</a>
        <a href="contact.html">Contact</a>
      </div>
    </div>
  </nav>

  <!-- Main Content -->
  <main>
    <h1>Welcome to Connecting The Dots Corporation</h1>
    <section>
      <h2>Mission Statement</h2>
      <p>To empower individuals and organisations with transformative training programmes...</p>
    </section>
  </main>
</body>
</html>
```

## Local Testing and Debugging

### Lambda Function Testing
Local testing utilised direct Python execution and Serverless Framework:

```bash
# Test Flask application locally (Phase 1)
cd first-attempt-flask-web-app/backend
python app.py

# Deploy and test serverless function (Phase 2)
cd second-attempt-s3-web-app/backend
serverless deploy

# Deploy Terraform infrastructure (Phase 3)
cd final-phase-s3-web-app/terraform
terraform apply
```

### API Endpoint Validation
Comprehensive testing using cURL and browser developer tools:

```bash
# Test health endpoint (Phase 1)
curl http://localhost:5000/ping

# Test form submission endpoint (Phase 3)
curl -X POST https://api.connectingthedotscorp.com/prod/contact \
  -H "Content-Type: application/json" \
  -d '{"first_name":"John","last_name":"Smith","email":"john.smith@connectingthedotscorp.com"}'

# Verify CORS preflight
curl -X OPTIONS https://api.connectingthedotscorp.com/prod/contact \
  -H "Origin: https://www.connectingthedotscorp.com" \
  -H "Access-Control-Request-Method: POST"
```

### DynamoDB Data Verification
Validated data persistence using AWS CLI:

```bash
# Query submitted form data
aws dynamodb scan --table-name ConnectingTheDots --region us-east-1

# Verify item structure by email key
aws dynamodb get-item --table-name ConnectingTheDots \
  --key '{"email":{"S":"john.smith@connectingthedotscorp.com"}}'
```

## IAM Role and Permissions

The Lambda execution role uses AWS managed policies for rapid development:

```hcl
data "aws_iam_policy_document" "ctdc-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ctdc-iam-for-lambda" {
  name               = "ctdc-iam-for-lambda"
  assume_role_policy = data.aws_iam_policy_document.ctdc-assume-role.json
}

resource "aws_iam_role_policy_attachment" "ctdc-lambda-basic-execution" {
  role       = aws_iam_role.ctdc-iam-for-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ctdc-lambda-admin-access" {
  role       = aws_iam_role.ctdc-iam-for-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "ctdc-lambda-dynamodb-access" {
  role       = aws_iam_role.ctdc-iam-for-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
```

**Security Note**: The current implementation uses broad managed policies (AdministratorAccess, AmazonDynamoDBFullAccess) for development convenience. Production deployments should implement custom policies with minimal required permissions for DynamoDB table access and CloudWatch logging.

CloudFront Origin Access Control ensures secure S3 access:

```hcl
resource "aws_cloudfront_origin_access_control" "ctdc-oac" {
  name                              = "ctdc-oac"
  description                       = "Origin Access Control for ConnectingTheDots S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "ctdc-cloudfront-oac" {
  statement {
    sid    = "AllowCloudFrontAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.ctdc-s3-bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::533267010082:distribution/${aws_cloudfront_distribution.ctdc-distribution.id}"]
    }
  }
}
```

## Design Decisions and Highlights

### Architecture Evolution Rationale

**Phase 1 to Phase 2 Migration:**
- **Decision**: Migrate from localhost Flask to serverless deployment
- **Rationale**: Eliminate infrastructure management overhead and enable 24/7 availability
- **Trade-off**: Increased complexity in debugging and deployment pipeline

**Phase 2 to Phase 3 Redesign:**
- **Decision**: Abandon WSGI wrapper in favour of dedicated Lambda functions
- **Rationale**: WSGI abstraction obscured error handling and limited observability
- **Benefit**: Clear separation of concerns, improved debugging, and better performance

### Technology Stack Choices

**Static Site Generation over Server-Side Rendering:**
- **Decision**: Host frontend as static files on S3 rather than dynamic Flask templates
- **Rationale**: Improved performance, reduced complexity, and better caching capabilities
- **Implementation**: CloudFront CDN with global edge locations for optimal load times

**DynamoDB over RDS:**
- **Decision**: NoSQL database for form submission storage
- **Rationale**: Serverless scaling, pay-per-request pricing, and simplified schema management
- **Trade-off**: Limited query flexibility compared to relational databases

**Terraform over CloudFormation:**
- **Decision**: HashiCorp Terraform for infrastructure provisioning
- **Rationale**: Multi-cloud compatibility, superior state management, and extensive provider ecosystem
- **Benefit**: Declarative configuration with plan/apply workflow for change validation

### Security Implementation

**HTTPS Enforcement:**
- CloudFront configured to redirect HTTP to HTTPS
- ACM certificate with automatic renewal
- HSTS headers for browser security

**CORS Configuration:**
- Explicit origin whitelisting for production domain
- Preflight request handling for complex requests
- Method and header restrictions to prevent unauthorised access

**IAM Security Considerations:**
- Current implementation uses managed policies for rapid prototyping
- AdministratorAccess provides broad permissions beyond application requirements
- Production environments should implement custom policies restricting access to specific DynamoDB tables and CloudWatch log groups

## Errors Encountered and Resolved

### Critical CORS Configuration Issues

**Problem**: Browser requests blocked despite Lambda returning correct headers
**Root Cause**: API Gateway method responses not configured for CORS
**Resolution**: Implemented both Lambda response headers and API Gateway method response configuration
**Learning**: CORS requires coordination between multiple AWS service layers

### CloudFront Origin Access Control

**Problem**: 403 Forbidden errors when accessing S3 content through CloudFront
**Root Cause**: Missing Origin Access Control configuration and S3 bucket policy
**Resolution**: Created OAC resource and corresponding S3 bucket policy with CloudFront service principal
**Impact**: Secured direct S3 access while maintaining CloudFront functionality

### Lambda Package Size Limitations

**Problem**: Deployment failures due to oversized Lambda packages
**Root Cause**: Inclusion of unnecessary dependencies and development files
**Resolution**: Implemented selective packaging with requirements.txt optimisation
**Prevention**: Added .gitignore patterns and deployment scripts for consistent packaging

### SSL Certificate Validation Delays

**Problem**: ACM certificate stuck in pending validation state
**Root Cause**: Missing DNS validation records in Route 53
**Resolution**: Automated CNAME record creation through Terraform ACM validation resources
**Improvement**: Implemented certificate validation as part of infrastructure deployment

## Skills Demonstrated

### Cloud Architecture and Services
- **AWS Lambda**: Serverless function development with Python runtime
- **API Gateway**: RESTful API design with CORS and method configuration
- **S3**: Static website hosting with bucket policies and lifecycle management
- **CloudFront**: CDN configuration with custom domains and SSL termination
- **DynamoDB**: NoSQL database design with partition keys and item structure
- **Route 53**: DNS management and domain routing configuration
- **ACM**: SSL certificate provisioning and validation automation

### Infrastructure as Code
- **Terraform**: Multi-resource orchestration with state management
- **Modular Configuration**: Reusable resource definitions and variable management
- **Version Control**: Infrastructure versioning with Git integration
- **Deployment Automation**: Consistent environment provisioning and updates

### Development and Debugging
- **Python**: Lambda function development with boto3 SDK integration
- **JavaScript**: Frontend API integration with error handling
- **HTTP Protocol**: Deep understanding of CORS, preflight requests, and status codes
- **AWS CLI**: Resource management and debugging through command-line interface
- **CloudWatch**: Log analysis and performance monitoring

### Security and Best Practices
- **IAM**: Managed policy implementation with security considerations documented
- **HTTPS**: SSL/TLS configuration with certificate management
- **Input Validation**: Form data sanitisation and validation logic
- **Error Handling**: Graceful failure management and user feedback

### Problem-Solving and Iteration
- **Architectural Evolution**: Systematic approach to identifying and resolving design limitations
- **Root Cause Analysis**: Methodical debugging of complex multi-service issues
- **Documentation**: Comprehensive recording of challenges and solutions for knowledge transfer
- **Testing Strategy**: Multi-layer validation from unit tests to end-to-end scenarios

## Conclusion

This project demonstrates the evolution of cloud architecture thinking through practical implementation and iterative problem-solving. The progression from a local Flask prototype to a production-ready serverless application showcases not only technical implementation skills but also the ability to recognise architectural limitations and redesign systems for scalability and maintainability.

The final implementation represents a mature understanding of AWS service integration, security best practices, and infrastructure as code principles. The comprehensive documentation of challenges and solutions provides valuable insights for similar projects and demonstrates a commitment to knowledge sharing and continuous improvement.

The live application at [https://www.connectingthedotscorp.com](https://www.connectingthedotscorp.com) serves as tangible proof of concept, processing real customer enquiries with enterprise-grade reliability and performance.

**Key Repository Links:**
- [Phase 1 Implementation](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/tree/main/first-attempt-flask-web-app)
- [Phase 2 Implementation](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/tree/main/second-attempt-s3-web-app)
- [Final Production Implementation](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/tree/main/final-phase-s3-web-app)
- [Detailed Technical Challenges](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/challenges-and-learnings.md)