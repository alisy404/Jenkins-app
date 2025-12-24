pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {
        // stage('Checkout Code') {
        //     steps {
        //         git 'https://github.com/alisy404/Jenkins-app.git'
        //     }
        // }
        stage('Terraform Init & Apply') {
            steps {
                withCredentials([
                [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                ]) {
                sh '''
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                '''
                }
            }
        }

  
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t jenkins-flask-app ./app'
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-key']) {
                sh """
                    EC2_IP=\$(terraform -chdir=terraform output -raw ec2_public_ip)

                    ssh -o StrictHostKeyChecking=no ec2-user@\${EC2_IP} '

                    sudo yum install -y docker || true
                    sudo systemctl enable docker

                    sudo systemctl start docker
                    sudo usermod -aG docker ec2-user

                    sudo docker stop flask || true
                    sudo docker rm flask || true

                    sudo docker build -t flask-app /home/ec2-user
                    sudo docker run -d -p 5000:5000 --name flask flask-app

                    '
                """
                }
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





                stage('Terraform Destroy (Manual Approval)') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                input message: 'Do you really want to DESTROY all AWS infrastructure?',
                    ok: 'Yes, destroy it'
                
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                        cd terraform
                        terraform destroy -auto-approve
                    '''
                }
            }
        }
    }
}
