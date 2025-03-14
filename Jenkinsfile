pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo/terraform-aurora.git'
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
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Apply Terraform Deployment') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

    }
}
