pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/your-username/jenkins-terraform-docker.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                sh '''
                  cd terraform
                  terraform init
                  terraform apply -auto-approve
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t jenkins-flask-app ./app'
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh '''
                EC2_IP=$(terraform -chdir=terraform output -raw ec2_public_ip)

                scp -o StrictHostKeyChecking=no \
                    app/Dockerfile app/app.py app/requirements.txt \
                    ec2-user@$EC2_IP:/home/ec2-user/

                ssh ec2-user@$EC2_IP << EOF
                  docker stop flask-app || true
                  docker rm flask-app || true
                  docker build -t flask-app .
                  docker run -d -p 5000:5000 --name flask-app flask-app
                EOF
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                EC2_IP=$(terraform -chdir=terraform output -raw ec2_public_ip)
                curl --fail http://$EC2_IP:5000/health
                '''
            }
        }
    }
}
