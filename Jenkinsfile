#!/usr/bin/env groovy
node('master') {
    try{
        stage('env'){

            checkout scm

            env.GIT_COMMIT_MSG = sh (script: 'git log -1 --pretty=%B ${GIT_COMMIT}', returnStdout: true).trim()
            env.EMAIL_TO = sh (script: 'git log -n 50 --pretty="%ce" | sort | uniq | grep -E "@(gmail.com|frc.org)" | tr \'\n\' \',\' | xargs | sed \'s/\\(.*\\),/\\1 /\'', returnStdout: true).trim()
            env.GIT_REPO_NAME = env.GIT_URL.replaceFirst(/^.*\/([^\/]+?).git$/, '$1')

            emailext    to: "${env.EMAIL_TO}",
                        body: "View build output here: $BUILD_URL/console\n\nLast Commit Message: ${env.GIT_COMMIT_MSG}",
                        subject: "${env.GIT_REPO_NAME} BUILD STARTING: ${env.BRANCH_NAME} : ${BUILD_ID}",
                        replyTo: 'eab@frc.org'

        }

//         stage('build'){
//             // build the image tagged with the current branch name
//             sh "docker build -t familyresearchcouncil/${env.GIT_REPO_NAME}:${env.BRANCH_NAME} ."
//         }

//         stage('setup') {
//             // start the services
//             sh 'docker-compose up -d'
//         }
//
//         stage('test') {
//              // check status code of http request
//
//             int status = sh(script: "curl -sLI -w '%{http_code}' localhost:3000 -o /dev/null", returnStdout: true)
//
//             if (status != 200 && status != 201) {
//                 error("Returned status code = $status when calling $url")
//             }
//
//         }

//         stage('push') {
//             // push the image to dockerhub so it is available to pull
//             sh "docker push familyresearchcouncil/${env.GIT_REPO_NAME}:${env.BRANCH_NAME}"
//         }

        stage('deploy') {
            sh "ssh docker01 mkdir -p /docker/containers/${env.GIT_REPO_NAME}"

            // copy the files necessary to deploy the application
            sh "scp deploy.sh docker01:/docker/containers/${env.GIT_REPO_NAME}"
            sh "scp docker-compose.yml docker01:/docker/containers/${env.GIT_REPO_NAME}"
            sh "scp docker-compose.main.yml docker01:/docker/containers/${env.GIT_REPO_NAME}/docker-compose.override.yml"

            // run the deploy script, passing the current branch as the argument
            sh "ssh docker01 /docker/containers/candidate-training/deploy.sh ${env.BRANCH_NAME}"

        }

    } catch(error) {
        emailext    to: "${env.EMAIL_TO}",
                    body: "View build output here: $BUILD_URL/console\n\nError ${error}",
                    subject: "${env.GIT_REPO_NAME} BUILD FAILED: ${env.BRANCH_NAME} : ${BUILD_ID}",
                    replyTo: 'eab@frc.org'

    } finally  {
//         sh 'docker-compose down'
    }

}
