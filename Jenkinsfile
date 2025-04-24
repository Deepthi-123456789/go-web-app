pipeline{
    agent any
     parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "Name of the Docker build", defaultValue: 'go-web-app')
        string(name: 'ImageTag', description: "Tag of the Docker build", defaultValue: 'latest')
        string(name: 'DockerHubUser', description: "DockerHub Username", defaultValue: 'deepthi555')
    }
     environment {
        GO_VERSION = "1.22"
        GO_ROOT = "/usr/local/go"
        PATH = "${GO_ROOT}/bin:${env.PATH}"
    }
    stages {
        stage('Checkout SCM') {
            when { expression { params.action == 'create' } }
            steps {
                sh '''
                    rm -rf go-web-app
                    git clone https://github.com/Deepthi-123456789/go-web-app.git
                '''
            }
        }
        stage('Build') {
            steps {
                script {
                    echo 'Building the Go web application...'
                    sh 'go build -o go-web-app ./main.go'
                }
            }
            echo "Build completed"
        }
        stage('Test') {
            steps {
                script {
                    echo 'Running tests...'
                    sh 'go test ./...'
                }
                echo "Tests completed"
            }
        }
        stage('Code Quality - golangci-lint') {
            steps {
                sh '''
                curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.55.2
                export PATH=$(go env GOPATH)/bin:$PATH
                golangci-lint run
                '''
            }
            echo "Code Quality Check completed"
        }
    
        stage('Docker Image Push : DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                echo "Starting Docker Image Push Stage"
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh "docker push ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag}"
                    }
                }
                echo "Docker Image Push completed"
            }
        }
        stage('Check Helm Version') {
            when { expression { params.action == 'create' } }
            steps {
                sh '''
                    helm version
                '''
            }
            echo "Helm installed and version check completed"
        }

        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying the application...'
                    // Add your deployment commands here
                }
            }
        }
    }
}