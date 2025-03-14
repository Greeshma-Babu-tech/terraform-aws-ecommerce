pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Greeshma-Babu-tech/terraform-aws-ecommerce.git'
            }
        }

        stage('Initialize Terraform') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Validate Terraform') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('Plan Terraform Deployment') {
            steps {
               withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'Greeshma-terraform', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                }
               sh 'terraform plan'
            }
        }

        stage('Apply Terraform Deployment') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

    }
}
