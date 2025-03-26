pipeline {
    agent any

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Выберите ветку для деплоя')
        booleanParam(name: 'RUN_DEPLOY', defaultValue: false, description: 'Выполнять ли деплой?')
    }

    environment {
        REPO_URL = 'git@github.com:Bella0708/users_app.git'
        TARGET_DIR = '/var/www/users.app'
        CURRENT_DIR = '/var/www/current'
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Ensure TARGET_DIR exists
                    sh "mkdir -p ${TARGET_DIR}"

                    if (!fileExists(TARGET_DIR)) {
                        checkout([$class: 'GitSCM', 
                            branches: [[name: "${params.BRANCH}"]], 
                            doGenerateSubmoduleConfigurations: false, 
                            extensions: [], 
                            submoduleCfg: [], 
                            userRemoteConfigs: [[credentialsId: 'jenkins_key', url: "${REPO_URL}"]]
                        ])
                    } else {
                        echo "Directory exists. Pulling latest changes."
                        dir(TARGET_DIR) {
                            sh "git pull origin ${params.BRANCH}"
                        }
                    }
                }
            }
        }

        stage('Check and Update Symlink') {
            steps {
                script {
                    // Ensure CURRENT_DIR exists
                    sh "mkdir -p ${CURRENT_DIR}"

                    if (fileExists(CURRENT_DIR)) {
                        echo "Updating symlink to the new version."
                        sh "ln -sfn ${TARGET_DIR} ${CURRENT_DIR}"
                    } else {
                        echo "Creating new symlink."
                        sh "ln -s ${TARGET_DIR} ${CURRENT_DIR}"
                    }
                }
            }
        }

        stage('Run Application') {
            when {
                expression { params.RUN_DEPLOY }
            }
            steps {
                script {
                    // Start the PHP server in the background
                    sh "php -S localhost:8000 -t ${CURRENT_DIR} &"
                    sleep 5 // Wait for the server to start
                }
            }
        }

        stage('Check Application Status') {
            steps {
                script {
                    // Check application status
                    def response = sh(script: "curl -f http://localhost:8000", returnStatus: true)
                    if (response != 0) {
                        error("Application is not running, curl failed.")
                    } else {
                        echo "Application is running successfully."
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
