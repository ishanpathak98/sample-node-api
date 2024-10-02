pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'your-region'
        ECR_REGISTRY = 'your-aws-account-id.dkr.ecr.your-region.amazonaws.com'
        ECR_REPOSITORY = 'your-ecr-repository'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}")
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${ECR_REGISTRY}", 'ecr:${AWS_DEFAULT_REGION}:your-aws-credentials-id') {
                        dockerImage.push()
                    }
                }
            }
        }
        
        stage('Deploy to EC2') {
            steps {
                script {
                    withAWS(credentials: 'your-aws-credentials-id', region: "${AWS_DEFAULT_REGION}") {
                        sh """
                            aws ssm send-command \
                                --document-name "AWS-RunShellScript" \
                                --targets "Key=tag:Name,Values=nodejs-api-instance" \
                                --parameters commands=[\
                                    "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}",\
                                    "docker pull ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}",\
                                    "docker stop nodejs-api || true",\
                                    "docker rm nodejs-api || true",\
                                    "docker run -d --name nodejs-api -p 3000:3000 ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"\
                                ]
                        """
                    }
                }
            }
        }
    }
}
