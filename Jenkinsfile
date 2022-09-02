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
    cron('0 1 * * 7')
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
    timeout(time: 20, unit: 'HOURS') 
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
          sh './frameworks/Kieker/python/benchmark.sh'
          sh './frameworks/Kieker/java/benchmark.sh'
          sh './frameworks/OpenTelemetry/benchmark.sh'
          sh './frameworks/inspectIT/benchmark.sh'

          sh 'cp frameworks/Kieker/python/results-python/results.yaml kieker-python-results.yaml'
          sh 'cp frameworks/Kieker/java/results-java/results.yaml kieker-java-results.yaml'
          sh 'cp frameworks/OpenTelemetry/results-OpenTelemetry/results.yaml open-telementry-results.yaml'
          sh 'cp frameworks/inspectIT/results-inspectIT/results.yaml inspect-it-results.yaml'

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
