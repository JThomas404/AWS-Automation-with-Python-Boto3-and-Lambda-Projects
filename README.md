# Serverless Web Application Project

This project was one of the most arduous and challenging I have undertaken. If you explore the directories below, you will see that I attempted this project multiple times — spending weeks on end, hours a day — only to hit a wall and start over. Each attempt failed for its own reasons, which I document in their respective directories and expand upon in [challenges-and-learnings.md](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/challenges-and-learnings.md).

I would be lying if I said it was not frustrating. At times, it felt like an insurmountable task — issue after issue, error after error. Every time I resolved one, another emerged. There were nights I considered scrapping the project entirely. But I did not. I restarted, restructured, re-architected, and learned.

Now, after three full implementations and months of methodical work, I have built a functioning, clean, and extensible serverless web application — with current plans to expand it further using Cognito (email + Google login authentication).

Live Site: [https://www.connectingthedotscorp.com](https://www.connectingthedotscorp.com)

---

## Project Structure

Each attempt is represented by its own directory, accompanied by dedicated documentation:

- [`first-attempt-flask-web-app/`](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/tree/main/first-attempt-flask-web-app) – Initial prototype (Flask app running locally on `localhost`)
- [`second-attempt-s3-web-app/`](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/tree/main/second-attempt-s3-web-app) – Second iteration (Flask deployed with WSGI, Lambda, and API Gateway)
- [`final-phase-s3-web-app/`](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/tree/main/final-phase-s3-web-app) – Final and current implementation (S3 static site with API Gateway and Lambda backend)
- [`challenges-and-learnings.md`](./challenges-and-learnings.md) – Comprehensive documentation of issues encountered, debugging processes, and key architectural insights

---

## Overview of Each Phase

### Phase 1 – Flask (Localhost)

[./flask-localhost directory](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/tree/main/first-attempt-flask-web-app) | [flask-localhost.md](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/flask-localhost.md)

This was the initial prototype: a web application built with Flask, running locally on `localhost`. It handled form submissions and stored data in DynamoDB using `boto3`.

Although functional, it lacked deployment capability. Since the Flask server had to run continuously on my local machine, it was neither scalable nor practical — which led me to explore a serverless alternative.

---

### Phase 2 – Serverless Flask with WSGI and Boto3

[./serverless-wsgi-flask directory](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/tree/main/second-attempt-s3-web-app) | [serverless-wsgi-flask.md](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/serverless-wsgi-flask.md)

This version introduced serverless deployment using the `serverless-wsgi` plugin. It wrapped the Flask app for use with AWS Lambda and exposed it via API Gateway. The backend still used `boto3` to interact with DynamoDB.

While the theory made sense, real-world usage proved difficult. WSGI obscured Lambda logs, CORS issues became persistent, and the deployment process was fragile. The architecture was not scalable or maintainable. This prompted a full redesign in Phase 3.

---

### Phase 3 – Static Site (S3 + Lambda + API Gateway)

[./final-phase-s3-web-app directory](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/tree/main/final-phase-s3-web-app) | [final-phase-s3-web-app.md](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/final-phase-s3-web-app.md)

This is the final implementation — minimal, stable, and properly structured.

The frontend is a static HTML/CSS site hosted on S3 and served via CloudFront under a custom domain with HTTPS. The backend is a Python Lambda function behind API Gateway, receiving `fetch()` requests and writing form data to DynamoDB. All infrastructure is provisioned through Terraform.

This version is production-ready: stable, secure, and scalable. It reflects everything I learned across the two prior attempts.

---

## What Works Now

- ✅ S3-hosted static frontend served via CloudFront with HTTPS and a custom domain
- ✅ API Gateway routes requests to Lambda
- ✅ Lambda validates and processes data
- ✅ DynamoDB stores form submissions
- ✅ All infrastructure managed via Terraform
- ✅ Clean logs and metrics visible in CloudWatch
- ✅ CORS handled correctly
- ✅ Error resilience and browser compatibility tested

---

## Validation and Testing

Validation of the deployed application included:

- Postman and cURL tests of Lambda and API Gateway response logic
- Full frontend form submission test on the live site
- Successful `200 OK` confirmations in browser developer tools

![Form Submission – Part 1](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/form-submission-pt1.png)  
![Form Submission – Part 2](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/images/form-submission-pt2.png)

---

## Current Work in Progress

I am currently implementing Cognito authentication (email/password + Google login), which is currently being configured in [`cognito.tf`](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/final-phase-s3-web-app/terraform/cognito.tf) & [`api-gateway.tf`](https://github.com/JThomas404/AWS-Automation-with-Python-Boto3-and-Lambda-Projects/blob/main/final-phase-s3-web-app/terraform/api-gateway.tf)

---

## Technologies Used

- **Frontend**: HTML, CSS
- **Backend**: Python (Lambda, Flask in earlier versions)
- **Cloud Services**: AWS (S3, Lambda, API Gateway, DynamoDB, CloudFront, Route 53, ACM)
- **Infrastructure as Code**: Terraform
- **Monitoring**: AWS CloudWatch
- **CI/CD**: GitHub Actions

---

## Future Plans

- Complete Cognito integration (email + Google sign-in)
- Create a protected user dashboard
- Apply cost optimisation practices (e.g., DynamoDB TTL, S3 lifecycle rules)
- Automate backups and security audits

---

## Contact Information

- **Email**: info@connectingthedotscorporation.com  
- **Website**: [www.connectingthedotscorporation.com](https://www.connectingthedotscorporation.com)

---

## References

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
- [Flask Documentation](https://flask.palletsprojects.com/en/stable/)
- [HTML and CSS Basics](https://www.w3schools.com/)

---

## Conclusion

This project was more than just technical execution — it was an exercise in problem-solving, persistence, and thinking like a cloud engineer should. Each failure required me to deepen my understanding, refine my design, and rebuild with greater precision.

I gained confidence in writing Terraform, troubleshooting Lambda and API Gateway integrations, configuring SSL and DNS, and building full-stack applications without traditional servers. More importantly, I learned how to approach problems with a practical, scalable mindset — not just to get things working, but to get them working well.

---