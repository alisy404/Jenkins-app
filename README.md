# Jenkins + Terraform + AWS CI/CD Project

This project demonstrates a complete CI/CD pipeline using Jenkins, Docker,
Terraform, and AWS EC2.

## Flow
1. Code pushed to GitHub
2. Jenkins pipeline triggered
3. Terraform provisions AWS EC2
4. Docker image built
5. Application deployed on EC2
6. Health check validates deployment

## Tech Stack
- Jenkins
- Docker
- Terraform
- AWS EC2
- Flask (Python)

## Access App
http://<EC2_PUBLIC_IP>:5000
# Jenkins-app
