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
        HOST = "18.217.152.167"
        TARGET_DIR = "${dir}/${prj}-${release}"
        CURRENT_DIR = "${dir}/current"
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

        stage('Run Application') {
            when {
                expression { params.RUN_DEPLOY }
            }
            steps {
                sshCommand remote: remote, command: """
                    echo "Starting application at ${CURRENT_DIR}"
                   /usr/bin/php -S localhost:8000 -t ${CURRENT_DIR} &
                    sleep 5
                """
            }
        }

        stage('Check Application Status') {
            steps {
                script {
                    echo "Checking application status at http://${env.HOST}:8000"
                    def response = sh(script: "curl -f http://${env.HOST}:8000", returnStatus: true)
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
