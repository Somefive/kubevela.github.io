pipeline {
    agent any
    environment {
        IMAGE_REGISTRY="registry.us-west-1.aliyuncs.com"
        IMAGE_REPO="kubevela-dev/kubevela.io"
        IMAGE_TAG="""${sh(
            returnStdout: true,
            script: 'git rev-parse --short HEAD | tr -d "\n"'
        )}"""
        IMAGE_NAME="$IMAGE_REPO:$IMAGE_TAG"
        IMAGE="$IMAGE_REGISTRY/$IMAGE_NAME"
        IMAGE_REGISTRY_CRED=credentials('kubevela-longterm-acr-credential')
    }
    stages {
        stage('Build') {
            steps {
                sh '''#!/bin/bash
                    set -ex
                    docker login -u $IMAGE_REGISTRY_CRED_USR -p $IMAGE_REGISTRY_CRED_PSW $IMAGE_REGISTRY
                    docker build -t $IMAGE .
                '''
            }
        }

        stage('Publish') {
            steps {
                sh '''
                    set -ex
                    docker push $IMAGE
                '''
            }
        }

        stage('Deploy') {
            environment {
                COMPONENT_NAME="kubevela-io"
                WEBHOOK_URL=credentials('kubevela-io-webhook-url')
            }
            steps {
                sh '''#!/bin/bash
                    set -ex
                    curl -X POST -H "Content-Type: application/json" -d '{"upgrade":{"'"$COMPONENT_NAME"'":{"image":"'"$IMAGE"'"}},"codeInfo":{"user":"'"$GIT_COMMITTER_NAME"'","commit":"'"$GIT_COMMIT"'","branch":"'"$GIT_BRANCH"'"}}' $WEBHOOK_URL
                '''
            }
        }
    }

    post {
       failure {
           updateGitlabCommitStatus name: 'build', state: 'failed'
       }
       success {
           updateGitlabCommitStatus name: 'build', state: 'success'
       }
    }
}