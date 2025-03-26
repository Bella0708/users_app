pipeline {
    agent any

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Выберите ветку для деплоя')
        booleanParam(name: 'RUN_DEPLOY', defaultValue: false, description: 'Выполнять ли деплой?')
    }

    environment {
        REPO_URL = 'git@github.com:Bella0708/users_app.git' // URL вашего репозитория
        TARGET_DIR = '/var/www/users.app'
        CURRENT_DIR = '/var/www/current'
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Проверяем, существует ли директория
                    if (!fileExists(TARGET_DIR)) {
                        // Клонируем репозиторий
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
                            // Переходим в директорию и обновляем
                            sh "git pull origin ${params.BRANCH}"
                        }
                    }
                }
            }
        }

        stage('Check and Update Symlink') {
            steps {
                script {
                    // Проверка существования симлинка
                    if (fileExists(CURRENT_DIR)) {
                        echo "Updating symlink to the new version."
                        // Обновляем симлинк
                        sh "ln -sfn ${TARGET_DIR} ${CURRENT_DIR}"
                    } else {
                        echo "Creating new symlink."
                        // Создаем новый симлинк
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
                    // Запускаем приложение на PHP
                    sh "php -S localhost:8000 -t ${CURRENT_DIR}" // Убедитесь, что путь правильный
                }
            }
        }
        
        stage('Check Application Status') {
            steps {
                script {
                    // Проверка состояния приложения
                    sh "curl -f http://localhost:8000" // Проверяем, что приложение работает
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
     
