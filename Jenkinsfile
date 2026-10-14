pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'aws-access-key-id',
                        variable: 'AWS_ACCESS_KEY_ID'
                    ),
                    string(
                        credentialsId: 'aws-secret-access-key',
                        variable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Validate') {
            steps {
                sh 'terraform fmt -check -recursive'
                sh 'terraform validate'
            }
        }

        stage('Plan') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'aws-access-key-id',
                        variable: 'AWS_ACCESS_KEY_ID'
                    ),
                    string(
                        credentialsId: 'aws-secret-access-key',
                        variable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh 'terraform plan -input=false -out=tfplan'
                }
            }
        }

        stage('Apply') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'aws-access-key-id',
                        variable: 'AWS_ACCESS_KEY_ID'
                    ),
                    string(
                        credentialsId: 'aws-secret-access-key',
                        variable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                    sh 'terraform output'
                }
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Terraform deployment completed.'
        }

        failure {
            echo 'FAILED: Check the Jenkins Console Output.'
        }

        always {
            deleteDir()
        }
    }
}