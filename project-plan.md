# Serverless Web Application Project Plan

## Overview
This project involves creating a **serverless web application** using **Flask**, **AWS Lambda**, **API Gateway**, and **DynamoDB**. The project is designed to give you practical hands-on experience in deploying serverless solutions on AWS while working with technologies such as **Infrastructure as Code** (IaC), **CI/CD pipelines**, and **security best practices**.

The goal of the project is to create a functional backend API that supports CRUD operations for user data and resources, along with a simple static frontend. This application will be entirely serverless, reducing management overhead and leveraging AWS's scalable and cost-efficient services.

---
## Project Plan Diagram

![Project Plan](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/raw/main/images/project_plan_diagram.png)

---

## Project Phases

### Phase 1: Infrastructure Setup
#### **Objective**:
Set up the necessary AWS services to support the serverless application.

Setting up **IAM roles** ensures proper access control and security by defining specific permissions for Lambda to interact with API Gateway and DynamoDB. **CloudFormation** or **Terraform** is used to define infrastructure in code, which promotes automation, consistency, and easy management of AWS resources. This also allows replication of the environment with minimal manual setup. **DynamoDB** provides a scalable, managed NoSQL database that can automatically adjust to growing data needs. **S3** is chosen for hosting the static frontend due to its cost-effectiveness and seamless integration with serverless applications, offering high durability and availability for static assets.

#### **Tasks**:
1. **Create IAM Roles**:
   - Set up AWS **IAM** roles with appropriate permissions for Lambda to interact with API Gateway and DynamoDB.
   
2. **Deploy Infrastructure using IaC (CloudFormation or Terraform)**:
   - Define resources such as **API Gateway**, **Lambda Functions**, and **DynamoDB** in **Terraform** templates for automated deployment.

3. **Set up DynamoDB**:
   - Create DynamoDB tables for storing user data, training resources, and progress tracking.

4. **Set up S3 for Static Files**:
   - Create an **S3 bucket** to host static files such as HTML, and CSS.

#### **Deliverables**:
- A Terraform template that defines the infrastructure resources (API Gateway, Lambda, DynamoDB).

---

### Phase 2: Backend API with Flask
#### **Objective**:
Build the backend API using **Flask** and deploy it to **AWS Lambda**.

Flask is chosen for its lightweight, easy-to-learn nature, allowing for rapid API development. **AWS Lambda** removes the need for server management, scaling automatically in response to traffic. By using **API Gateway** to route requests to Lambda, I can efficiently expose the Flask application as a REST API. **DynamoDB** is used for CRUD operations as it offers a scalable, fully managed solution that integrates seamlessly with serverless applications, enabling fast data storage and retrieval.

#### **Tasks**:
1. **Create Flask Application**:
   - Build a Flask application with **CRUD endpoints** (POST, GET, PUT, DELETE) for managing resources and user data.

2. **Deploy Flask App to Lambda**:
   - Use **AWS SAM (Serverless Application Model)** to deploy the Flask app to **AWS Lambda**.

3. **Set up API Gateway**:
   - Configure an **API Gateway** to route HTTP requests to the Lambda functions.

4. **Connect Flask App to DynamoDB**:
   - Implement logic to interact with **DynamoDB** for storing and retrieving data.

#### **Deliverables**:
- A fully functional Flask API deployed to AWS Lambda.
- Configured API Gateway to route requests to the Lambda functions.

---

### Phase 3: Simple Frontend
#### **Objective**:
Build a static frontend that interacts with the backend API.

A static frontend using **HTML** and **CSS** is chosen to keep the project lightweight and easy to implement. This approach ensures that the focus remains on learning AWS serverless technologies while still providing the user with a fully functional web application. By using the **Fetch API**, the frontend can communicate directly with the backend API to manage user data. Hosting on **S3** allows for low-cost, high-durability static file storage and reduces the need for additional infrastructure.

#### **Tasks**:
1. **Create HTML and CSS**:
   - Build the basic HTML structure and apply CSS for a simple, responsive design.

2. **Use JavaScript to Make API Calls**:
   - Implement the **Fetch API** to send requests to the backend API for user interaction.

3. **Host Frontend on S3**:
   - Deploy static assets to **S3** for cost-efficient hosting.

#### **Deliverables**:
- Static frontend files hosted on **S3**.
- Simple forms and UI elements for interacting with the backend API.

---

### Phase 4: CI/CD Pipeline
#### **Objective**:
Automate the deployment of both the frontend and backend using **GitHub Actions**.

Implementing a **CI/CD pipeline** is essential for automating testing, building, and deploying code, reducing human error, and accelerating the delivery of new features. **GitHub Actions** integrates seamlessly with AWS and automates the deployment of both the backend API (to Lambda) and the frontend (to S3). By using **unit tests**, I can ensure that the Lambda functions behave as expected, catching bugs early in the development process and improving code reliability.

#### **Tasks**:
1. **Set up GitHub Actions**:
   - Create a CI/CD pipeline with **GitHub Actions** to automatically test, build, and deploy the Flask app to AWS Lambda and static files to S3.

2. **Write Unit Tests**:
   - Write simple **unit tests** for Lambda functions to ensure they work as expected.

#### **Deliverables**:
- A GitHub Actions pipeline for automated deployment of both frontend and backend.
- Unit tests to validate Lambda functions.

---

### Phase 5: Basic Security and Monitoring
#### **Objective**:
Add basic security and monitoring features to the application.

Security is a crucial consideration even in simple applications. By using **API key-based authentication** in API Gateway, I can restrict access to the backend API, ensuring that only authorized users can interact with it. **CloudWatch** is set up to track the performance and logs of Lambda functions and API Gateway requests, providing insights into application performance and errors. These practices ensure that the application is secure, maintainable, and scalable.

#### **Tasks**:
1. **API Key Authentication**:
   - Implement **API key-based security** for API Gateway to restrict access to the backend API.

2. **CloudWatch Logging and Monitoring**:
   - Set up **CloudWatch Logs** to track Lambda function executions and API Gateway requests.

#### **Deliverables**:
- API Gateway secured with API keys.
- CloudWatch Logs for monitoring Lambda and API Gateway performance.

---

## Key Learning Outcomes
1. **Serverless Architecture**: Hands-on experience with **AWS Lambda**, **API Gateway**, and **DynamoDB**.
2. **Infrastructure Automation**: Learning how to use **Terraform** for deploying AWS resources.
3. **CI/CD Pipeline**: Implementing automated deployment and testing using **GitHub Actions**.
4. **API Development**: Gain experience in building, deploying, and managing APIs using **Flask** and **AWS Lambda**.
5. **Security and Monitoring**: Understanding the fundamentals of **security** and **monitoring** within a serverless application.

---

## Tools and Technologies
- **AWS Lambda** for serverless compute.
- **API Gateway** for HTTP routing.
- **DynamoDB** for NoSQL database storage.
- **S3** for static website hosting.
- **CloudFormation** or **Terraform** for infrastructure as code.
- **GitHub Actions** for CI/CD.
- **Flask** for the backend API.
- **Zappa** or **AWS SAM** for deploying Flask to Lambda.

---

## Project Timeline
- **Week 1**: Set up the infrastructure (Phase 1) and deploy the backend API (Phase 2).
- **Week 2**: Build and deploy the static frontend (Phase 3), then set up CI/CD (Phase 4).
- **Week 3**: Implement basic security (Phase 5) and complete documentation.

---