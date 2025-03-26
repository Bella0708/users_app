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
        stage('Set Permissions') {
            steps {
                script {
                    // Установка прав доступа к каталогу /var/www
                    echo "Setting permissions for /var/www"
                    sh "sudo chown -R jenkins:jenkins /var/www"
                    sh "sudo chmod -R 755 /var/www"
                }
            }
        }

        stage('Clone Repository') {
            steps {
                script {
                    // Убедитесь, что TARGET_DIR существует
                    sh "sudo mkdir -p ${TARGET_DIR}"

                    // Клонируем или обновляем репозиторий
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
                            sh "sudo git pull origin ${params.BRANCH}"
                        }
                    }
                }
            }
        }

        stage('Check and Update Symlink') {
            steps {
                script {
                    // Убедитесь, что CURRENT_DIR существует
                    sh "sudo mkdir -p ${CURRENT_DIR}"

                    // Удаляем существующий симлинк, если он есть
                    if (fileExists(CURRENT_DIR)) {
                        echo "Removing existing symlink."
                        sh "sudo rm -f ${CURRENT_DIR}"
                    }

                    // Создаем новый симлинк
                    echo "Creating new symlink."
                    sh "sudo ln -s ${TARGET_DIR} ${CURRENT_DIR}"
                }
            }
        }

        stage('Run Application') {
            when {
                expression { params.RUN_DEPLOY }
            }
            steps {
                script {
                    // Запускаем приложение на PHP
                    sh "php -S localhost:8000 -t ${CURRENT_DIR} &"
                    sleep 5 // Ждем, чтобы сервер успел запуститься
                }
            }
        }

        stage('Check Application Status') {
            steps {
                script {
                    // Проверка состояния приложения
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
