#!/usr/bin/env groovy

pipeline {

  agent { 
     docker {
          image 'prefec2/moobench:latest'
          alwaysPull true
          args env.DOCKER_ARGS
     }
  }

  triggers {
    cron('0 1 * * 6')
    // upstream(upstreamProjects: 'kieker-dev/master', threshold: hudson.model.Result.SUCCESS)
  }

  environment {
    KEYSTORE = credentials('kieker-irl-key')
    UPDATE_SITE_URL = "sftp://repo@repo.se.internal/moobench"
    DOCKER_ARGS = ''
    BATCH_MODE = "yes"
  }

  options {
    buildDiscarder logRotator(artifactNumToKeepStr: '10')
    timeout(time: 168, unit: 'HOURS') 
    retry(1)
    parallelsAlwaysFailFast()
  }

  stages {
    stage('Initial Cleanup') {
       steps {
          sh './gradlew clean'
       }
    }

    stage('Compile') {
       steps {
          sh './setup.sh'
       }
    }

    stage('Run Benchmark') {
       steps {
          sh './frameworks/Kieker-python/benchmark.sh'
          sh './frameworks/Kieker-java/benchmark.sh'
          sh './frameworks/OpenTelemetry-java/benchmark.sh'
          sh './frameworks/inspectIT-java/benchmark.sh'

          sh 'cp frameworks/Kieker-python/results/results.yaml Kieker-python-results.yaml'
          sh 'cp frameworks/Kieker-java/results/results.yaml Kieker-java-results.yaml'
          sh 'cp frameworks/OpenTelemetry-java/results/results.yaml OpenTelemetry-java-results.yaml'
          sh 'cp frameworks/inspectIT-java/results/results.yaml inspectIT-java-results.yaml'

          stash includes: '*-results.yaml', name: 'yaml'
       }
    }
    
    stage('Upload') {
       steps {
          sshagent(credentials: ['kieker-irl-key']) {
             unstash 'yaml'
             sh "./upload.sh ${KEYSTORE} ${UPDATE_SITE_URL}"
          }
       }
       post {
         cleanup {
           deleteDir()
           cleanWs()
         }
       }
    }
  }
}
