pipeline {
  agent any

  environment {
    PROJECT = 'sul-dlss/SearchWorks'
  }

  stages {
    stage('Stage deploy') {
      environment {
        DEPLOY_ENVIRONMENT = 'stage'
      }

      when {
        branch 'master'
      }

      steps {
        checkout scm

        sshagent (['sul-devops-team', 'sul-continuous-deployment']){
          sh '''#!/bin/bash -l
          export DEPLOY=1

          # Load RVM
          rvm use 3.0.3@searchworks --create
          gem install bundler

          bundle install --without production

          # Deploy it
          bundle exec cap $DEPLOY_ENVIRONMENT deploy
          '''
        }
      }

      post {
        always {
          build job: '/Continuous Deployment/Slack Deployment Notification', parameters: [
            string(name: 'PROJECT', value: env.PROJECT),
            string(name: 'GIT_COMMIT', value: env.GIT_COMMIT),
            string(name: 'GIT_URL', value: env.GIT_URL),
            string(name: 'GIT_PREVIOUS_SUCCESSFUL_COMMIT', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT),
            string(name: 'DEPLOY_ENVIRONMENT', value: env.DEPLOY_ENVIRONMENT),
            string(name: 'TAG_NAME', value: env.TAG_NAME),
            booleanParam(name: 'SUCCESS', value: currentBuild.resultIsBetterOrEqualTo('SUCCESS')),
            string(name: 'RUN_DISPLAY_URL', value: env.RUN_DISPLAY_URL)
          ]
        }
      }
    }

    stage('UAT deploy') {
      environment {
        DEPLOY_ENVIRONMENT = 'uat'
      }

      when {
        branch 'master'
      }

      steps {
        checkout scm

        sshagent (['sul-devops-team', 'sul-continuous-deployment']){
          sh '''#!/bin/bash -l
          export DEPLOY=1

          # Load RVM
          rvm use 3.0.3@searchworks --create
          gem install bundler

          bundle install --without production

          # Deploy it
          bundle exec cap $DEPLOY_ENVIRONMENT deploy
          '''
        }
      }

      post {
        always {
          build job: '/Continuous Deployment/Slack Deployment Notification', parameters: [
            string(name: 'PROJECT', value: env.PROJECT),
            string(name: 'GIT_COMMIT', value: env.GIT_COMMIT),
            string(name: 'GIT_URL', value: env.GIT_URL),
            string(name: 'GIT_PREVIOUS_SUCCESSFUL_COMMIT', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT),
            string(name: 'DEPLOY_ENVIRONMENT', value: env.DEPLOY_ENVIRONMENT),
            string(name: 'TAG_NAME', value: env.TAG_NAME),
            booleanParam(name: 'SUCCESS', value: currentBuild.resultIsBetterOrEqualTo('SUCCESS')),
            string(name: 'RUN_DISPLAY_URL', value: env.RUN_DISPLAY_URL)
          ]
        }
      }
    }

    stage('sdr-prod preview deploy') {
      environment {
        DEPLOY_ENVIRONMENT = 'preview_prod'
      }

      when {
        tag "v*"
      }

      steps {
        checkout scm

        sshagent (['sul-devops-team', 'sul-continuous-deployment']){
          sh '''#!/bin/bash -l
          export DEPLOY=1

          # Load RVM
          rvm use 3.0.3@searchworks --create
          gem install bundler

          bundle install --without production

          # Deploy it
          bundle exec cap $DEPLOY_ENVIRONMENT deploy
          '''
        }
      }

      post {
        always {
          build job: '/Continuous Deployment/Slack Deployment Notification', parameters: [
            string(name: 'PROJECT', value: env.PROJECT),
            string(name: 'GIT_COMMIT', value: env.GIT_COMMIT),
            string(name: 'GIT_URL', value: env.GIT_URL),
            string(name: 'GIT_PREVIOUS_SUCCESSFUL_COMMIT', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT),
            string(name: 'DEPLOY_ENVIRONMENT', value: env.DEPLOY_ENVIRONMENT),
            string(name: 'TAG_NAME', value: env.TAG_NAME),
            booleanParam(name: 'SUCCESS', value: currentBuild.resultIsBetterOrEqualTo('SUCCESS')),
            string(name: 'RUN_DISPLAY_URL', value: env.RUN_DISPLAY_URL)
          ]
        }
      }
    }

    stage('sdr-stage preview deploy') {
      environment {
        DEPLOY_ENVIRONMENT = 'preview_stage'
      }

      when {
        tag "v*"
      }

      steps {
        checkout scm

        sshagent (['sul-devops-team', 'sul-continuous-deployment']){
          sh '''#!/bin/bash -l
          export DEPLOY=1

          # Load RVM
          rvm use 3.0.3@searchworks --create
          gem install bundler

          bundle install --without production

          # Deploy it
          bundle exec cap $DEPLOY_ENVIRONMENT deploy
          '''
        }
      }

      post {
        always {
          build job: '/Continuous Deployment/Slack Deployment Notification', parameters: [
            string(name: 'PROJECT', value: env.PROJECT),
            string(name: 'GIT_COMMIT', value: env.GIT_COMMIT),
            string(name: 'GIT_URL', value: env.GIT_URL),
            string(name: 'GIT_PREVIOUS_SUCCESSFUL_COMMIT', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT),
            string(name: 'DEPLOY_ENVIRONMENT', value: env.DEPLOY_ENVIRONMENT),
            string(name: 'TAG_NAME', value: env.TAG_NAME),
            booleanParam(name: 'SUCCESS', value: currentBuild.resultIsBetterOrEqualTo('SUCCESS')),
            string(name: 'RUN_DISPLAY_URL', value: env.RUN_DISPLAY_URL)
          ]
        }
      }
    }

    stage('gryphon uat/preview deploy') {
      environment {
        DEPLOY_ENVIRONMENT = 'preview_gryphon'
      }

      when {
        branch "master"
      }

      steps {
        checkout scm

        sshagent (['sul-devops-team', 'sul-continuous-deployment']){
          sh '''#!/bin/bash -l
          export DEPLOY=1

          # Load RVM
          rvm use 3.0.3@searchworks --create
          gem install bundler

          bundle install --without production

          # Deploy it
          bundle exec cap $DEPLOY_ENVIRONMENT deploy
          '''
        }
      }

      post {
        always {
          build job: '/Continuous Deployment/Slack Deployment Notification', parameters: [
            string(name: 'PROJECT', value: env.PROJECT),
            string(name: 'GIT_COMMIT', value: env.GIT_COMMIT),
            string(name: 'GIT_URL', value: env.GIT_URL),
            string(name: 'GIT_PREVIOUS_SUCCESSFUL_COMMIT', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT),
            string(name: 'DEPLOY_ENVIRONMENT', value: env.DEPLOY_ENVIRONMENT),
            string(name: 'TAG_NAME', value: env.TAG_NAME),
            booleanParam(name: 'SUCCESS', value: currentBuild.resultIsBetterOrEqualTo('SUCCESS')),
            string(name: 'RUN_DISPLAY_URL', value: env.RUN_DISPLAY_URL)
          ]
        }
      }
    }

    stage('morison deploy') {
      environment {
        DEPLOY_ENVIRONMENT = 'preview_morison'
      }

      when {
        tag "v*"
      }

      steps {
        checkout scm

        sshagent (['sul-devops-team', 'sul-continuous-deployment']){
          sh '''#!/bin/bash -l
          export DEPLOY=1

          # Load RVM
          rvm use 3.0.3@searchworks --create
          gem install bundler

          bundle install --without production

          # Deploy it
          bundle exec cap $DEPLOY_ENVIRONMENT deploy
          '''
        }
      }

      post {
        always {
          build job: '/Continuous Deployment/Slack Deployment Notification', parameters: [
            string(name: 'PROJECT', value: env.PROJECT),
            string(name: 'GIT_COMMIT', value: env.GIT_COMMIT),
            string(name: 'GIT_URL', value: env.GIT_URL),
            string(name: 'GIT_PREVIOUS_SUCCESSFUL_COMMIT', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT),
            string(name: 'DEPLOY_ENVIRONMENT', value: env.DEPLOY_ENVIRONMENT),
            string(name: 'TAG_NAME', value: env.TAG_NAME),
            booleanParam(name: 'SUCCESS', value: currentBuild.resultIsBetterOrEqualTo('SUCCESS')),
            string(name: 'RUN_DISPLAY_URL', value: env.RUN_DISPLAY_URL)
          ]
        }
      }
    }

    stage('folio-dev deploy') {
      environment {
        DEPLOY_ENVIRONMENT = 'preview_folio'
      }

      when {
        branch 'master'
      }

      steps {
        checkout scm

        sshagent (['sul-devops-team', 'sul-continuous-deployment']){
          sh '''#!/bin/bash -l
          export DEPLOY=1

          # Load RVM
          rvm use 3.0.3@searchworks --create
          gem install bundler

          bundle install --without production

          # Deploy it
          bundle exec cap $DEPLOY_ENVIRONMENT deploy
          '''
        }
      }

      post {
        always {
          build job: '/Continuous Deployment/Slack Deployment Notification', parameters: [
            string(name: 'PROJECT', value: env.PROJECT),
            string(name: 'GIT_COMMIT', value: env.GIT_COMMIT),
            string(name: 'GIT_URL', value: env.GIT_URL),
            string(name: 'GIT_PREVIOUS_SUCCESSFUL_COMMIT', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT),
            string(name: 'DEPLOY_ENVIRONMENT', value: env.DEPLOY_ENVIRONMENT),
            string(name: 'TAG_NAME', value: env.TAG_NAME),
            booleanParam(name: 'SUCCESS', value: currentBuild.resultIsBetterOrEqualTo('SUCCESS')),
            string(name: 'RUN_DISPLAY_URL', value: env.RUN_DISPLAY_URL)
          ]
        }
      }
    }

    stage('Prod deploy (on release)') {
      environment {
        DEPLOY_ENVIRONMENT = 'prod'
      }

      when {
        tag "v*"
      }

      steps {
        checkout scm

        sshagent (['sul-devops-team', 'sul-continuous-deployment']){
          sh '''#!/bin/bash -l
          export DEPLOY=1
          export REVISION=$TAG_NAME

          # Load RVM
          rvm use 3.0.3@searchworks --create
          gem install bundler

          bundle install --without production

          # Deploy it
          bundle exec cap $DEPLOY_ENVIRONMENT deploy
          '''
        }
      }

      post {
        always {
          build job: '/Continuous Deployment/Slack Deployment Notification', parameters: [
            string(name: 'PROJECT', value: env.PROJECT),
            string(name: 'GIT_COMMIT', value: env.GIT_COMMIT),
            string(name: 'GIT_URL', value: env.GIT_URL),
            string(name: 'GIT_PREVIOUS_SUCCESSFUL_COMMIT', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT),
            string(name: 'DEPLOY_ENVIRONMENT', value: env.DEPLOY_ENVIRONMENT),
            string(name: 'TAG_NAME', value: env.TAG_NAME),
            booleanParam(name: 'SUCCESS', value: currentBuild.resultIsBetterOrEqualTo('SUCCESS')),
            string(name: 'RUN_DISPLAY_URL', value: env.RUN_DISPLAY_URL)
          ]
        }
      }
    }
  }
}
