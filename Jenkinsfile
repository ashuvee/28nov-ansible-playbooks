pipeline {
    agent any



    environment {
        SONAR_URL = credentials('sonar-url')
        NEXUS_URL = credentials('nexus-url')
        DOCKER_REGISTRY = "docker.io"
        // TODO: Update with your Docker Hub username
        IMAGE_NAME = "ashuz/password-generator"
        TOMCAT_URL = credentials('tomcat-url')
        NEXUS_USERNAME = "admin"
        NEXUS_PASSWORD = "admin123"
        INVENTORY = credentials('hosts-ini')
    }

    stages {
        stage('Checkout') {
            steps {
                // TODO: Update with your actual Git repository URL
                git branch: 'main', url: 'https://github.com/ashuvee/28nov-ansible-playbooks.git'
            }
        }

        stage('Maven Build') {
            steps {
                ansiblePlaybook(
                    playbook: 'playbooks/ci.yml',
                    inventory: "${INVENTORY}",
                    installation: 'Ansible-Default',
                    credentialsId: 'ssh-key',
                    disableHostKeyChecking: true,
                    colorized: true,
                    tags: 'build',
                    extraVars: [
                        workspace: "${WORKSPACE}"
                    ]
                )
            }
        }

        stage('Unit Tests') {
            steps {
                ansiblePlaybook(
                    playbook: 'playbooks/ci.yml',
                    inventory: "${INVENTORY}",
                    installation: 'Ansible-Default',
                    credentialsId: 'ssh-key',
                    disableHostKeyChecking: true,
                    colorized: true,
                    tags: 'test',
                    extraVars: [
                        workspace: "${WORKSPACE}"
                    ]
                )
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    ansiblePlaybook(
                        playbook: 'playbooks/ci.yml',
                        inventory: "${INVENTORY}",
                        installation: 'Ansible-Default',
                        credentialsId: 'ssh-key',
                        disableHostKeyChecking: true,
                        colorized: true,
                        tags: 'sonar',
                        extraVars: [
                            workspace: "${WORKSPACE}",
                            sonar_url: "${SONAR_URL}",
                            sonar_token: "${SONAR_TOKEN}",
                            build_number: "${BUILD_NUMBER}"
                        ]
                    )
                }
            }
        }

        stage('Maven Package') {
            steps {
                ansiblePlaybook(
                    playbook: 'playbooks/ci.yml',
                    inventory: "${INVENTORY}",
                    installation: 'Ansible-Default',
                    credentialsId: 'ssh-key',
                    disableHostKeyChecking: true,
                    colorized: true,
                    tags: 'package',
                    extraVars: [
                        workspace: "${WORKSPACE}"
                    ]
                )
            }
        }

        stage('Deploy to Nexus') {
            steps {
                ansiblePlaybook(
                    playbook: 'playbooks/ci.yml',
                    inventory: "${INVENTORY}",
                    installation: 'Ansible-Default',
                    credentialsId: 'ssh-key',
                    disableHostKeyChecking: true,
                    colorized: true,
                    tags: 'nexus',
                    extraVars: [
                        workspace: "${WORKSPACE}",
                        nexus_url: "${NEXUS_URL}"
                    ]
                )
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    ansiblePlaybook(
                        playbook: 'playbooks/ci.yml',
                        inventory: "${INVENTORY}",
                        installation: 'Ansible-Default',
                        credentialsId: 'ssh-key',
                        disableHostKeyChecking: true,
                        colorized: true,
                        tags: 'docker',
                        extraVars: [
                            workspace: "${WORKSPACE}",
                            image_name: "${IMAGE_NAME}",
                            build_number: "${BUILD_NUMBER}",
                            docker_user: "${DOCKER_USER}",
                            docker_pass: "${DOCKER_PASS}"
                        ]
                    )
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                ansiblePlaybook(
                    playbook: 'playbooks/deploy.yml',
                    inventory: "${INVENTORY}",
                    installation: 'Ansible-Default',
                    credentialsId: 'ssh-key',
                    disableHostKeyChecking: true,
                    colorized: true
                )
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline completed successfully! App deployed to ${TOMCAT_URL}"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
