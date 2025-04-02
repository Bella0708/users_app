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
        HOST = "18.191.137.115"
        TARGET_DIR = "${dir}/${prj}-${release}"
        CURRENT_DIR = "${dir}/current"
    }

    stages {
        stage('Check PHP Availability') {
            steps {
                script {
                    echo "Checking PHP version..."
                    sh "which php"
                    sh "/usr/bin/php -v"
                }
            }
        }

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
                script {
                    echo "Setting permissions for ${dir}"
                    sh "sudo chown -R jenkins:jenkins ${dir}"
                    sh "sudo chmod -R 755 ${dir}"
                }
            }
        }

        stage('Clone Repository') {
            steps {
                script {
                    sh "mkdir -p ${TARGET_DIR}"
                    echo "Cloning repository into ${TARGET_DIR}"
                    sh "git clone ${REPO_URL} ${TARGET_DIR}"
                }
            }
        }

        stage('Update Symlink') {
            steps {
                script {
                    echo "Updating symlink to point to ${TARGET_DIR}"
                    sh "ln -sfn ${TARGET_DIR} ${CURRENT_DIR}"
                }
            }
        }

        stage('Run Application') {
            when {
                expression { params.RUN_DEPLOY }
            }
            steps {
                script {
                    echo "Starting application at ${CURRENT_DIR}"
                    sh "/usr/bin/php -S localhost:8000 -t ${CURRENT_DIR} &"
                    sleep 5
                }
            }
        }

        stage('Check Application Status') {
            steps {
                script {
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
