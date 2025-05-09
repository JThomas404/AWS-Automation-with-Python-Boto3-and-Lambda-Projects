# Serverless Web Application Project

## Overview

This project involves building a **serverless web application** for **ConnectingTheDots Corporation**, a company dedicated to advancing sustainable development through innovative training programs. The objective of this project is to create a serverless web application with an API backend that facilitates user interaction with training services, helping users access sustainability-focused resources.

A few years ago, the founder (my mother) approached me to create a website for her. At that time, I built a simple static HTML website using WordPress. Recently, I decided to update the website by hosting a static site on AWS, which also provided an opportunity to improve my cloud engineering skills. This project has allowed me to gain hands-on experience with APIs, Python, Terraform, and more.

The web application will include the following features:
- A **REST API** for managing user data and training program information.
- A **frontend** that interacts with the API, displaying resources and user progress.
- Integration with **AWS cloud services**, including **Lambda functions**, **API Gateway**, **S3**, and **DynamoDB**.
- A **simple authentication system** for user management.

## Contents

- [Project Plan](project-plan.md)
- [API Documentation](api-documentation.md)
- [Cloud Architecture](cloud-architecture.md)
- [Challenges & Learnings](challenges-and-learnings.md)

## Project Goals

The core objectives of this project are:
1. **API Development**: Learn how to design and deploy serverless REST APIs using **Flask** and **AWS Lambda**.
2. **Serverless Architecture**: Utilise **AWS Lambda** and **API Gateway** to build a serverless backend, reducing infrastructure management complexity.
3. **Infrastructure as Code (IaC)**: Implement **Terraform** for deploying cloud resources.
4. **CI/CD Pipeline**: Build a **CI/CD pipeline** to automate deployments and testing.
5. **Cloud Security and Best Practices**: Implement AWS best practices for security, monitoring, and performance.

## Technologies Used

- **Frontend**: HTML, CSS
- **Backend**: Python (Flask framework)
- **Cloud**: AWS (Lambda, API Gateway, S3, DynamoDB)
- **Infrastructure as Code**: Terraform
- **CI/CD**: GitHub Actions

## Challenges Faced

Building projects often comes with challenges, particularly when there is a steep learning curve. It's inevitable that something will go wrong, whether it's code not functioning as expected or issues with the API. These challenges were essential in helping me grow as a cloud engineer. I have documented the significant issues I faced and how I resolved them in the [Challenges & Learnings](challenges-and-learnings.md) section of the repo.

## Future Plans

After completing the core features, I plan to:
- Optimise the serverless application for performance.
- Optimise AWS resource costs using the **BASH script** in the [AWS Cost Monitoring Script](https://github.com/JThomas404/AWS-Cost-Monitoring-Script) repo.
- Implement detailed logging and monitoring for AWS resources using **CloudWatch**.

## Company's Contact Info

- **Email**: info@connectingthedotscorporation.com
- **Website**: [www.connectingthedotscorporation.com](http://www.connectingthedotscorporation.com) (Website to be updated after project completion)

---


* Add the references and guides i used in this project in a reference table
Terraform registry: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

Python/Boto3/Flask: https://www.w3schools.com/python/default.asp; https://boto3.amazonaws.com/v1/documentation/api/latest/index.html; https://flask.palletsprojects.com/en/stable/

HTML/CSS: https://www.w3schools.com/css/default.asp;https://www.w3schools.com/html/default.asp

