pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        timeout(time: 60, unit: 'MINUTES')
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
                    sh '''
                        set -eu

                        terraform plan \
                            -input=false \
                            -out=tfplan

                        terraform show -no-color tfplan > tfplan.txt

                        echo "Terraform plan generated successfully."
                    '''

                    echo 'Displaying Terraform plan for review:'
                    sh 'cat tfplan.txt'
                }
            }
        }

        stage('Manual Approval') {
            steps {
                script {
                    def approval = timeout(
                        time: 15,
                        unit: 'MINUTES'
                    ) {
                        input(
                            message: """
EC2 Deployment Approval Required

Environment: Development
AWS Region: ${env.AWS_DEFAULT_REGION}

Review the Terraform plan in the Jenkins console.

Do you approve the Terraform changes and EC2 creation?
""",
                            ok: 'Approve Deployment',
                            submitter: 'admin,devops-lead',
                            submitterParameter: 'APPROVED_BY'
                        )
                    }

                    env.TERRAFORM_APPROVED_BY =
                        approval.toString()

                    echo "Deployment approved by: ${env.TERRAFORM_APPROVED_BY}"
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
                    sh '''
                        set -eu

                        terraform apply -input=false -auto-approve tfplan
                        terraform output
                    '''
                }
            }
        }
    }

    post {
        success {
            echo """
            SUCCESS: Terraform deployment completed.
            Approved by: ${env.TERRAFORM_APPROVED_BY}
            """
        }

        aborted {
            echo '''
            ABORTED: Deployment was cancelled, rejected,
            or approval timed out.
            Terraform Apply was not executed if cancellation
            occurred before the Apply stage.
            '''
        }

        failure {
            echo 'FAILED: Check the Jenkins Console Output.'
        }

        always {
            deleteDir()
        }
    }
}
