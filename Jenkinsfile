pipeline {
    agent { label 'build' }  // Run on build-01

    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
    }

    environment {
        SONAR_URL = "http://sonar-01:9000"
        NEXUS_URL = "http://nexus-01:8081"
        DOCKER_REGISTRY = "docker.io"
        // TODO: Update with your Docker Hub username
        IMAGE_NAME = "ashuz/password-generator"
        TOMCAT_URL = "http://tomcat-01:8080"
        NEXUS_USERNAME = "admin"
        NEXUS_PASSWORD = "admin123"
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
                sh 'mvn clean compile'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
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
                    sh '''
                        mvn sonar:sonar \
                          -Dsonar.projectKey=password-generator-${BUILD_NUMBER} \
                          -Dsonar.projectName=PasswordGenerator \
                          -Dsonar.host.url=${SONAR_URL} \
                          -Dsonar.login=${SONAR_TOKEN}
                    '''
                }
            }
        }

        stage('Maven Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Deploy to Nexus') {
            steps {
                sh '''
                    mvn deploy -DskipTests \
                      -DaltDeploymentRepository=nexus-releases::default::${NEXUS_URL}/repository/maven-releases/
                '''
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def dockerImage = docker.build("${IMAGE_NAME}:${BUILD_NUMBER}", "-f Dockerfile .")
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "docker-hub-token") {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                sh '''
                    curl -u deployer:deployer123 --upload-file target/ROOT.war \
                         ${TOMCAT_URL}/manager/text/deploy?path=/&update=true
                '''
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
