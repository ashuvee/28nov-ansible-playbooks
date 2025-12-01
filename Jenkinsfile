pipeline {
    agent any

    environment {
        SONAR_URL = credentials('sonar-url')
        NEXUS_URL = credentials('nexus-url')
        DOCKER_REGISTRY = "docker.io"
        IMAGE_NAME = "ashuz/password-generator"
        TOMCAT_URL = credentials('tomcat-url')
        NEXUS_USERNAME = "admin"
        NEXUS_PASSWORD = "admin123"
        INVENTORY = credentials('hosts-ini')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ashuvee/28nov-ansible-playbooks.git'
            }
        }

        stage('Maven Build') {
            steps { runAnsible('build') }
        }

        stage('Unit Tests') {
            steps { runAnsible('test') }
            post {
                always {
                    script {
                        if (fileExists('target/surefire-reports')) {
                            junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
                        } else {
                            echo 'No test results found - skipping test report'
                        }
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    runAnsible('sonar', [
                        sonar_url: "${SONAR_URL}",
                        sonar_token: "${SONAR_TOKEN}",
                        build_number: "${BUILD_NUMBER}"
                    ])
                }
            }
        }

        stage('Maven Package') {
            steps { runAnsible('package') }
        }

        stage('Deploy to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-cred', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    runAnsible('nexus', [
                        nexus_url: "${NEXUS_URL}",
                        nexus_username: "${NEXUS_USER}",
                        nexus_password: "${NEXUS_PASS}"
                    ])
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    runAnsible('docker', [
                        image_name: "${IMAGE_NAME}",
                        build_number: "${BUILD_NUMBER}",
                        docker_user: "${DOCKER_USER}",
                        docker_pass: "${DOCKER_PASS}"
                    ])
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                ansiblePlaybook(
                    playbook: 'playbooks/deploy.yml',
                    inventory: "${INVENTORY}",
                    credentialsId: 'ssh-key',
                    disableHostKeyChecking: true,
                    colorized: true
                )
            }
        }
    }

    post {
        always {
            script {
                // Run cleanup before deleting workspace
                try {
                    runAnsible('cleanup', [build_number: "${BUILD_NUMBER}"])
                } catch (Exception e) {
                    echo "Cleanup failed: ${e.message}"
                }
            }
            cleanWs()
        }
        success { echo "Deployed to ${TOMCAT_URL}" }
        failure { echo "Pipeline failed." }
    }
}

def runAnsible(String tags, Map extraVars = [:]) {
    // Default variables
    def vars = [
        workspace: "${WORKSPACE}",
        build_number: "${BUILD_NUMBER}"
    ]
    vars << extraVars

    ansiblePlaybook(
        playbook: 'playbooks/ci.yml',
        inventory: "${INVENTORY}",
        credentialsId: 'ssh-key',
        disableHostKeyChecking: true,
        colorized: true,
        tags: tags,
        extraVars: vars
    )
}
