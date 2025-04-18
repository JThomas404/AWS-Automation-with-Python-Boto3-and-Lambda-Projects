# Serverless Web Application Project Plan

## Overview
This project involves creating a **serverless web application** using **Flask**, **AWS Lambda**, **API Gateway**, and **DynamoDB**. It provides hands-on experience in deploying serverless solutions on AWS while working with technologies such as **Infrastructure as Code** (IaC), **CI/CD pipelines**, and **security best practices**.

The objective is to build a functional backend API that supports CRUD operations for user data and resources, along with a static frontend. The application will be entirely serverless, minimising management overhead and leveraging AWS’s scalable, cost-effective services.

---
## Project Plan Diagram

![Project Plan](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/raw/main/images/project_plan_diagram.png)

---

## Project Phases

### Phase 1: Infrastructure Setup
#### **Objective**:
Set up the necessary AWS services for the serverless application.

This phase involves creating **IAM roles** to ensure proper access control and security, using **Infrastructure as Code (IaC)** with **CloudFormation** or **Terraform** for resource management, and setting up **DynamoDB** for data storage. **S3** will host the static frontend, providing high durability and availability.

#### **Tasks**:
1. **Create IAM Roles**:
   - Set up IAM roles with the required permissions for Lambda to interact with API Gateway and DynamoDB.

2. **Deploy Infrastructure Using IaC**:
   - Define infrastructure resources such as API Gateway, Lambda functions, and DynamoDB using **Terraform** templates for automated deployment.

3. **Set Up DynamoDB**:
   - Create DynamoDB tables for storing user data, training resources, and progress tracking.

4. **Set Up S3 for Static Files**:
   - Create an S3 bucket for hosting static files such as HTML and CSS.

#### **Deliverables**:
- A Terraform template that defines the infrastructure resources (API Gateway, Lambda, DynamoDB).

---

### Phase 2: Backend API with Flask
#### **Objective**:
Develop the backend API using **Flask** and deploy it to **AWS Lambda**.

Flask is chosen for its lightweight nature, allowing for rapid development. **AWS Lambda** handles server management, automatically scaling based on demand. **API Gateway** routes HTTP requests to the Lambda functions, and **DynamoDB** will store and retrieve data.

#### **Tasks**:
1. **Create Flask Application**:
   - Develop a Flask app with CRUD endpoints (POST, GET, PUT, DELETE) for managing user data and resources.

2. **Deploy Flask App to Lambda**:
   - Use **AWS SAM (Serverless Application Model)** to deploy the Flask app to AWS Lambda.

3. **Set Up API Gateway**:
   - Configure API Gateway to route HTTP requests to Lambda.

4. **Connect Flask App to DynamoDB**:
   - Implement logic for interacting with DynamoDB to perform CRUD operations.

#### **Deliverables**:
- A fully functional Flask API deployed to AWS Lambda.
- Configured API Gateway to route requests to Lambda functions.

---

### Phase 3: Frontend
#### **Objective**:
Build a static frontend that interacts with the backend API.

The frontend will be built using **HTML** and **CSS**, with JavaScript handling the interaction with the backend via the **Fetch API**. The static files will be hosted on **S3** for efficient, low-cost delivery.

#### **Tasks**:
1. **Create HTML and CSS**:
   - Build the HTML structure and apply CSS for a responsive design.

2. **Use JavaScript for API Interaction**:
   - Implement the Fetch API to interact with the backend API.

3. **Host Frontend on S3**:
   - Deploy static files to an S3 bucket.

#### **Deliverables**:
- Static frontend files hosted on S3.
- Forms and UI elements for interacting with the backend API.

---

### Phase 4: CI/CD Pipeline
#### **Objective**:
Automate deployment using **GitHub Actions**.

A **CI/CD pipeline** will be set up to automate testing, building, and deploying both the backend and frontend. **GitHub Actions** will be used to deploy the backend to AWS Lambda and the frontend to S3. Unit tests will ensure the Lambda functions are working as expected.

#### **Tasks**:
1. **Set Up GitHub Actions**:
   - Create a CI/CD pipeline to automatically test, build, and deploy the Flask app and frontend.

2. **Write Unit Tests**:
   - Write unit tests for Lambda functions to validate their functionality.

#### **Deliverables**:
- A GitHub Actions pipeline for automated deployment.
- Unit tests for Lambda functions.

---

### Phase 5: Security and Monitoring
#### **Objective**:
Implement security measures and monitoring for the application.

**API key-based authentication** will secure the API, restricting access to authorised users. **CloudWatch** will be used to track Lambda and API Gateway performance, ensuring the application runs efficiently and securely.

#### **Tasks**:
1. **API Key Authentication**:
   - Implement API key-based security for API Gateway to restrict access.

2. **CloudWatch Monitoring**:
   - Set up CloudWatch logs to monitor Lambda function executions and API Gateway requests.

#### **Deliverables**:
- API Gateway secured with API keys.
- CloudWatch logs for monitoring performance.

---

## Key Learning Outcomes
1. **Serverless Architecture**: Practical experience with **AWS Lambda**, **API Gateway**, and **DynamoDB**.
2. **Infrastructure Automation**: Learn to use **Terraform** to deploy AWS resources.
3. **CI/CD Pipeline**: Automate deployment and testing using **GitHub Actions**.
4. **API Development**: Gain experience in building and deploying APIs using **Flask** and **AWS Lambda**.
5. **Security and Monitoring**: Understand security best practices and monitoring for serverless applications.

---

## Tools and Technologies
- **AWS Lambda** for serverless compute.
- **API Gateway** for HTTP routing.
- **DynamoDB** for NoSQL database storage.
- **S3** for static website hosting.
- **CloudFormation** or **Terraform** for infrastructure as code.
- **GitHub Actions** for CI/CD.
- **Flask** for the backend API.

---

## Project Timeline
- **Week 1**: Set up infrastructure (Phase 1) and deploy the backend API (Phase 2).
- **Week 2**: Build and deploy the static frontend (Phase 3), then set up CI/CD (Phase 4).
- **Week 3**: Implement security (Phase 5) and complete documentation.

--- 