# Serverless Web Application Project

This project was one of the most arduous and challenging ones I have done. If you look at the directories linked below, you’ll see that I attempted this project multiple times — spending weeks on end, hours a day — only to hit a wall and be forced to start again. Each attempt failed for its own reasons, which I’ll detail in their respective directories and expand further in [`challenges-learnings.md`](challenges-learnings.md).

I would be lying if I said it wasn’t frustrating. At times it felt like an insurmountable task — issue after issue, error after error. And every time I’d resolve one, it would give way to another. There were nights I considered scrapping it altogether. But I didn’t. I restarted, restructured, re-architected, and learned.

Now, after three full implementations and months of slow, methodical work, I’ve built a functioning, clean, and extensible serverless web application — with current plans to expand it further using Cognito (email + Google login authentication).

Link to the Connecting The Dots Web Application Here: https://www.connectingthedotscorp.com

---

## 📁 Project Structure

Each attempt has its own directory and its own documentation:

- [`flask-localhost/`](./flask-localhost) – First attempt (Flask app running locally)  
- [`serverless-wsgi-flask/`](./serverless-wsgi-flask) – Second attempt (Flask deployed with WSGI, Lambda, API Gateway)  
- [`final-phase-s3-web-app/`](./final-phase-s3-web-app) – Final and current implementation (S3 static site + API Gateway + Lambda)
- [`challenges-learnings`](challenges-learnings.md) – The detailed documentation of all the errors, debugging i encountered throughout this project.

Each has its own `Markdown` explaining the structure, decisions, and why it eventually needed to be restarted.

---

## Overview of Each Phase

### Phase 1 – Flask (Localhost)

📁 [Directory](./flask-localhost) | 📄 [Details](flask-localhost.md)

This was the starting point — a Web application utilising Flask running locally on `localhost`. It handled form submission and wrote to DynamoDB using `boto3`.

It was functional, but not deployable, however, due to the fact the Flask needed to be running continuously on my local machine terminal, i needed to restart the project with a more practical, cost-effective solution. Hence why I decided to go with a serverless solution.

---

### Phase 2 – Serverless Flask with WSGI & Boto3

📁 [Directory](./serverless-wsgi-flask) | 📄 [Details](serverless-wsgi-flask.md)

The second version aimed to make Flask work serverlessly using the `serverless-wsgi` plugin. It involved zipping the Flask app, setting up API Gateway to route to Lambda through WSGI, and still writing to DynamoDB using Boto3.

This was my first time deploying a Flask app via Lambda. The theory made sense. The reality was different. WSGI made Lambda opaque to debug. CORS became an endless issue. The packaging process was rigid. And when something broke, tracing it took hours. The architecture eventually became too tangled to scale or maintain. I made the rational decision to start over again, and simplify the architecture to utilise AWS resources rather than Flask and WSGI servers.

---

### Phase 3 – Static Site (S3 + Lambda + API Gateway)

📁 [Directory](./final-phase-s3-web-app) | 📄 [Details](final-phase-s3-web-app.md)

This is the current implementation — stripped back, simplified, and finally structured correctly.

The frontend is a static HTML/CSS/JS site hosted on S3, served via CloudFront under HTTPS with a custom domain. The backend is a Python Lambda function exposed via API Gateway. Form data is sent using JavaScript `fetch()` and stored in DynamoDB. The entire infrastructure is managed via Terraform.

This version works. It’s stable, extensible, and easier to maintain. More importantly, it reflects everything I’ve learned from the two failed implementations before it.

---

## What Works Now

- ✅ S3-hosted static frontend served over HTTPS (CloudFront + ACM)
- ✅ API Gateway routes to Lambda
- ✅ Lambda processes and validates form data
- ✅ DynamoDB stores submissions
- ✅ Full Terraform infrastructure (modular, reusable)
- ✅ Custom domains for frontend and backend (Route 53)
- ✅ CORS handled properly
- ✅ Logs and errors visible in CloudWatch

---

## My Planned Next Steps

I am currently in adding Cognito authentication (email/password + Google login) which can be found in [cognito.tf](terraform/cognito.tf)


---

# Conclusion

As tedious and challenging this project was for me i was an incredible learning experience. i had to from breakdown issues, understanding errors, reforming my developer skills. reiteraing the Terraform and Lambda code helped me gain a lot of experience and i am a lot more confindent with terraform, python, and the AWS services than i was going into this project which can be accreddited to the fact that i had to rebuild and i had to think like a cloud engineer should, finding the more practical solution rather than what works, but rather what works best.
























# Serverless Web Application Project

This project was one of the most arduous and challenging ones I have done. If you look at the directories which i have linked below, you would see that i attmpted this project multiple times. spending weeks on end for hours a day, to needing to start over again from scratch. Each for time their own reasons which i will address in detail in challenges-learnings.md

i would be lying if i said it was not frustrating, belieiving this was an insurmountable challenge to overcome - issue after issue - error after each step - once debugged and resolved ramifying into a new error.

I am proud to say the after the three attempts and months of working at it step by step, i managed to successfully complete this project. with current plans of adding additional contingencies Cognito (email+google auth login).

Contents page: 

The first attempt (first-attempt-flask-web-app/) 
second attempt (hosted serverless using flask, wsgi, and boto3)



# The First Attempt:Flask Web App
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

