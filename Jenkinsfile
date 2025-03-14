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
               // sh 'terraform plan'
               sh 'terraform plan -var="AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -var="AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"'
            }
        }

        stage('Apply Terraform Deployment') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

    }
}
