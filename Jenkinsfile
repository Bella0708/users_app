def remote = [:]
pipeline {
    agent any

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Выберите ветку для деплоя')
        booleanParam(name: 'RUN_DEPLOY', defaultValue: false, description: 'Выполнять ли деплой?')
    }

    environment {
        dir = "/var/www"
        prj = "users_app"
        release = sh(script: "date +%s", returnStdout: true).trim()
        REPO_URL = "git@github.com:Bella0708/users_app.git"
        HOST = "18.117.171.233"
        TARGET_DIR = "${dir}/${prj}-${release}"
        CURRENT_DIR = "${dir}/current"
        DOCKER_COMPOSE_FILE = "docker-compose.yaml" // Добавлен путь к docker-compose.yml
    }

    stages {
        stage('Configure Credentials') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins_key', keyFileVariable: 'private_key', usernameVariable: 'username')]) {
                    script {
                        remote.name = "${env.HOST}"
                        remote.host = "${env.HOST}"
                        remote.user = username
                        remote.identity = readFile(private_key)
                        remote.allowAnyHosts = true
                    }
                }
            }
        }

        stage('Set Permissions') {
            steps {
                sshCommand remote: remote, command: """
                    set -ex ; set -o pipefail
                    echo "Setting permissions for ${dir}"
                     sudo chown -R jenkins:jenkins ${dir}
                     sudo chmod -R 755 ${dir}
                """
                }
        }

        stage('Clone Repository') {
            steps {
                sshCommand remote: remote, command: """
                     mkdir -p ${TARGET_DIR}
                    echo "Cloning repository into ${TARGET_DIR}"
                    git clone ${REPO_URL} ${TARGET_DIR}
                """
            }
        }

        stage('Update Symlink') {
            steps {
                sshCommand remote: remote, command: """
                    echo "Updating symlink to point to ${TARGET_DIR}"
                    ln -sfn ${TARGET_DIR} ${CURRENT_DIR}
                """
            }
        }

        stage('Deploy Docker Containers') { // Добавлен этап запуска контейнеров Docker
            steps {
                sshCommand remote: remote, command: """
                    cd ${CURRENT_DIR}
                    echo "Deploying Docker containers using ${DOCKER_COMPOSE_FILE}"
                    docker-compose -f ${DOCKER_COMPOSE_FILE} down || true
                    docker-compose -f ${DOCKER_COMPOSE_FILE} up -d
                """
            }
        }

        stage('Check Application Status') {
            steps {
                script {
                    echo "Checking application status at http://${env.HOST}:8080"
                    def response = sh(script: "curl -f http://${env.HOST}:8080", returnStatus: true)
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
