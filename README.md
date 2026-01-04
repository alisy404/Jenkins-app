## 🧩 Overview
  
**JENK-APP** is a production-style, single-click CI/CD project that demonstrates how modern DevOps teams build, deploy, validate, and clean up applications automatically.

With a single Jenkins pipeline run, this project performs the complete application lifecycle without manual intervention.

### What this project does
+ Provisions AWS infrastructure using Terraform
+ Builds and containerizes a Flask application with Docker
+ Deploys the container to an EC2 instance
+ Performs automated health checks
+ Optionally destroys all infrastructure to avoid cloud cost

This is not a demo script — it reflects real-world DevOps workflows.

---

## 🛠️ Technology Stack

+ Jenkins – CI/CD orchestration
+ Terraform – Infrastructure as Code
+ Docker – Containerization
+ Amazon EC2 – Compute layer
+ AWS – Cloud platform
+ Flask – Application framework

---

## 📁 Project Structure

.
├── app/                    # Application source
│   ├── app.py              # Flask app + health endpoint
│   ├── Dockerfile          # Docker build instructions
│   └── requirements.txt    # Python dependencies
│
├── terraform/              # Infrastructure as Code
│   ├── main.tf             # EC2, subnet, SG, IGW
│   ├── variables.tf
│   ├── outputs.tf          # Exposes EC2 public IP
│   └── terraform.tfvars
│
├── Jenkinsfile              # Complete CI/CD pipeline
├── README.md
└── .gitignore

---

## 🔄 CI/CD Pipeline Architecture

### 1. Source Code Checkout
+ Jenkins pulls the repository from GitHub
+ Pipeline execution begins using the Jenkinsfile

---

### 2. Infrastructure Provisioning (Terraform)

Terraform automatically provisions the following AWS resources:

+ EC2 instance
+ Public subnet
+ Internet Gateway
+ Route table and subnet association
+ Security Group with:
  + Port 22 (SSH)
  + Port 5000 (Application)

Output Handling
+ The EC2 public IP is exported by Terraform
+ Jenkins dynamically reuses this IP in later stages

---

### 3. Docker Image Build (CI Stage)
+ Jenkins builds the Flask application Docker image using:
  + python:3.12-slim
+ Image is optimized for:
  + Faster build times
  + Smaller image size

---

### 4. Deployment to EC2 (CD Stage)

Deployment is performed using the Jenkins SSH Agent:

+ Docker is installed and started on the EC2 instance
+ Repository is cloned on the target EC2 host
+ Docker image is built directly on EC2
+ Container is started and exposed on:
  + Port 5000

+ No manual SSH or server access is required

---

### 5. Automated Health Check
+ Jenkins validates the deployment by calling:
  + GET /health

Expected Response:
```json
{"status":"UP"}

---

### 6. Manual Approval & Infrastructure Teardown

+ Jenkins pauses execution and waits for manual confirmation  
+ On approval, Terraform destroys all provisioned resources:
  ```bash
  terraform destroy -auto-approve

---

🔹 Run the Application Locally (Without Docker)
        cd app
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
        python app.py


    Access:

        http://localhost:5000
        http://localhost:5000/health

🔹 Dockerize & Run Locally

        cd app
        docker build -t flask-app .
        docker run -d -p 5000:5000 --name flask flask-app


Test:

        curl http://localhost:5000/health


Cleanup:

        docker stop flask
        docker rm flask

🔹 Test Terraform Locally (Dry Run)

---

⚠️ Requires AWS credentials configured locally

        cd terraform
        terraform init
        terraform plan


Optional (creates real AWS resources):

        terraform apply
        terraform destroy


_____________________________________________________________________________________________________________________________

🎯 Why This Project Is Strong

    True CI + CD + Infrastructure as Code integration
    Dynamic data flow between Terraform and Jenkins
    Automated, health-based deployment validation
    Secure handling of AWS and SSH credentials
    Manual approval gate for safe infrastructure destruction
    Fully reproducible and cost-safe design

_____________________________________________________________________________________________________________________________



THANK YOU----