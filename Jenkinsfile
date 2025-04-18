pipeline {
  environment {
    IMAGE_NAME = "staticwebsite"
    APP_CONTAINER_PORT = "5000"
    APP_EXPOSED_PORT = "80"
    IMAGE_TAG = "latest"
    STAGING = "chocoapp-staging-123"
    PRODUCTION = "chocoapp-prod-123"
    DOCKERHUB_ID = "walidmajdoubi"
    DOCKERHUB_PASSWORD = credentials('dockerhub_password')
  }
  agent none
  stages {
    stage('Build image') {
      agent any
      steps {
        script {
          sh 'docker build -t ${DOCKERHUB_ID}/${IMAGE_NAME}:${IMAGE_TAG} .'
        }
      }
    }
    stage('Run container based on built image') {
      agent any
      steps {
        script {
          sh '''
            echo "Cleaning existing container if exist"
            docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME
            docker run --name $IMAGE_NAME -d -p $APP_EXPOSED_PORT:$APP_CONTAINER_PORT -e PORT=$APP_CONTAINER_PORT ${DOCKERHUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}
            sleep 5
          '''
        }
      }
    }
    stage('Test image') {
      agent any
      steps {
        script {
          sh '''
            curl localhost | grep -i "Dimension"
          '''
        }
      }
    }
    stage('Clean container') {
      agent any
      steps {
        script {
          sh '''
            docker stop $IMAGE_NAME
            docker rm $IMAGE_NAME
          '''
        }
      }
    }
    stage('Login and Push image on Dockerhub') {
      agent any
      steps {
        script {
          sh '''
            echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_ID --password-stdin
            docker push ${DOCKERHUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}
          '''
        }
      }
    }
    stage('Push image in staging and deploy it') {
      when {
        expression { GIT_BRANCH == 'origin/main' }
      }
      agent any
      environment {
        HEROKU_API_KEY = credentials('heroku_api_key')
      }
      steps {
        script {
          sh '''
            heroku container:login
            heroku apps:info -a $STAGING || heroku create $STAGING
            heroku container:push -a $STAGING web
            heroku container:release -a $STAGING web
          '''
        }
      }
    }
    stage('Push image in production and deploy it') {
      when {
        expression { GIT_BRANCH == 'origin/main' }
      }
      agent any
      environment {
        HEROKU_API_KEY = credentials('heroku_api_key')
      }
      steps {
        script {
          sh '''
            heroku container:login
            heroku apps:info -a $PRODUCTION || heroku create $PRODUCTION
            heroku container:push -a $PRODUCTION web
            heroku container:release -a $PRODUCTION web
          '''
        }
      }
    }
  }
  post {
    always {
      script {
        slackNotifier currentBuild.result
      }
    }
  }
}
