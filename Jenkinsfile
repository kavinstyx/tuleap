pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'tuleap'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = 'tuleap'
        TULEAP_URL = 'http://tuleap.local:8180'  // Update with your Tuleap URL
        GIT_REPO = 'git@tuleap.local:22/your-project/your-repo.git'  // Update with your repo
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
                    // Stop and remove any existing containers
                    sh '''
                        #!/bin/bash
                        if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true
                        fi
                        
                        # Build the Docker image
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    '''
                }
            }
        }
        
        stage('Run Tuleap Container') {
            steps {
                script {
                    sh """
                        #!/bin/bash
                        # Run the Tuleap container with custom ports
                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            --hostname tuleap.local \
                            --privileged \
                            -p 8180:80 \
                            -p 4443:443 \
                            -p 2222:22 \
                            -v ${WORKSPACE}/tuleap_data:/data \
                            -e "DEFAULT_DOMAIN=localhost" \
                            -e "ORG_NAME=Tuleap" \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        # Wait for Tuleap to be ready
                        echo "Waiting for Tuleap to be ready..."
                        until curl -s --head --request GET ${TULEAP_URL} | grep "200" > /dev/null; do 
                            sleep 30
                            echo "Waiting for Tuleap..."
                        done
                    """
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    // Example: Run integration tests against the running Tuleap instance
                    sh '''
                        #!/bin/bash
                        # Install test dependencies
                        python -m pip install --upgrade pip
                        pip install pytest requests
                        
                        # Run tests
                        python -m pytest tests/
                    '''
                    
                    // Example: Verify Git operations
                    sh """
                        #!/bin/bash
                        set -e
                        
                        # Create a test repository
                        TEST_REPO="test-repo-${BUILD_NUMBER}"
                        mkdir -p /tmp/${TEST_REPO}
                        cd /tmp/${TEST_REPO}
                        
                        # Configure Git to trust the host
                        mkdir -p ~/.ssh
                        ssh-keyscan -p 2222 tuleap.local >> ~/.ssh/known_hosts
                        
                        # Clone the repository
                        git clone ssh://git@tuleap.local:2222/${GIT_REPO} .
                        
                        # Make a change and push
                        echo "Test change" >> README.md
                        git config --global user.email "jenkins@example.com"
                        git config --global user.name "Jenkins"
                        git add .
                        git commit -m "Test commit from Jenkins"
                        git push origin master
                    """
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Clean up
                sh '''
                    #!/bin/bash
                    # Stop and remove the container
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    
                    # Clean up Docker images
                    docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                '''
            }
            
            // Archive test results
            junit '**/target/*.xml'
            
            // Clean workspace
            cleanWs()
        }
    }
}
