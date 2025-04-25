pipeline {
    agent any

    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/Destroy')
        string(name: 'ImageName', defaultValue: 'go-web-app', description: 'Name of the Docker build')
        string(name: 'ImageTag', defaultValue: 'v1', description: 'Tag of the Docker build')
        string(name: 'DockerHubUser', defaultValue: 'deepthi555', description: 'DockerHub Username')
    }

    environment {
        GO_VERSION = "1.22"
        GO_ROOT = "/usr/local/go"
        PATH = "${GO_ROOT}/bin:${env.PATH}"
    }

    stages {
        stage('Checkout SCM') {
            when {
                expression { params.action == 'create' }
            }
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
                    sh '''
                        cd go-web-app
                        go build -o go-web-app
                    '''
                    echo "Build completed"
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    echo 'Running tests...'
                    sh '''
                        cd go-web-app
                        go test ./...
                    '''
                    echo "Tests completed"
                }
            }
        }

        stage('Code Quality - golangci-lint') {
            steps {
                script {
                    echo "Running golangci-lint..."
                    sh '''
                        curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.55.2
                        export PATH=$(go env GOPATH)/bin:$PATH
                        cd go-web-app
                        golangci-lint run
                    '''
                    echo "Code Quality Check completed"
                }
            }
        }

        stage('Docker Image Build') {
            when { expression { params.action == 'create' } }
            steps {
                sh '''
                    echo "Checking contents of go-web-app directory..."
                    cd go-web-app
                    ls -al
                    docker build -t ${DockerHubUser}/${ImageName}:${ImageTag} .
                '''
            }
        }

        stage('Docker Image Push : DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                echo "Starting Docker Image Push Stage"
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                            docker push ${DockerHubUser}/${ImageName}:${ImageTag}
                        '''
                    }
                }
                echo "Docker Image Push completed"
            }
        }

        stage('Check Kubernetes Cluster') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo "Installing eksctl and kubectl..."

                    // Install eksctl
                   sh '''
                        curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
                        sudo mv /tmp/eksctl /usr/local/bin
                    '''
                    echo "eksctl installation completed"


                    // Install kubectl
                    sh '''
                        curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/latest/bin/linux/amd64/kubectl
                        chmod +x ./kubectl
                        sudo mv ./kubectl /usr/local/bin
                    '''

                    echo "Creating Kubernetes cluster..."
                    sh 'eksctl create cluster --name go-web-app-cluster --region us-east-1'
                    echo "Kubernetes cluster creation completed"
                }
            }
        }

        stage('Check Helm Version') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                script {
                    echo "Installing Helm..."
                    sh '''
                        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                    '''
                    echo "Checking Helm version..."
                    sh 'helm version'
                    echo "Helm installed and version check completed"
                }
            }
        }
        stage('ArgoCD Setup') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                script {
                    echo "Installing ArgoCD..."
                    sh '''
                        kubectl create namespace argocd
                        kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
                        kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
                        kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'
                    '''
                    echo "ArgoCD setup completed"
                }
            }
        }

        stage('Deploy') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                script {
                    echo 'Deploying the application...'
                    sh '''
                        cd go-web-app/helm/go-web-app-chart
                        helm install go-web-app-chart
                    '''
                    // Add Helm install/upgrade or kubectl apply logic here
                }
            }
        }
    }
}
