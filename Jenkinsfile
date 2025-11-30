pipeline {
    agent { label 'build' }  // Run on build-01

    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
    }

    environment {
        SONAR_URL = credentials('sonar-url')
        NEXUS_URL = credentials('nexus-url')
        DOCKER_REGISTRY = "docker.io"
        // TODO: Update with your Docker Hub username
        IMAGE_NAME = "ashuz/password-generator"
        TOMCAT_URL = credentials('tomcat-url')
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
                sh 'mvn -s settings.xml clean compile'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn -s settings.xml test'
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
                        mvn -s settings.xml sonar:sonar \
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
                sh 'mvn -s settings.xml package -DskipTests'
            }
        }

        stage('Deploy to Nexus') {
            steps {
                sh '''
                    mvn -s settings.xml deploy -DskipTests \
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
                withCredentials([usernamePassword(credentialsId: 'tomcat-cred', usernameVariable: 'TOMCAT_USER', passwordVariable: 'TOMCAT_PASS')]) {
                    sh '''
                        curl -u ${TOMCAT_USER}:${TOMCAT_PASS} --upload-file target/ROOT.war \
                             ${TOMCAT_URL}/manager/text/deploy?path=/&update=true
                    '''
                }
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
