pipeline {
  environment {
    registry = "apovyshev/devops_project"
    registryCredential = 'docker'
  }
  parameters {
    string(name: 'repository_url', defaultValue: 'git@github.com:apovyshev/project.git', description: 'Github repository url')
    booleanParam(name: 'build_and_run_docker', defaultValue: true, description: 'Deploy and run Docker for tests')
	booleanParam(name: 'deploy_in_prod', defaultValue: false, description: 'Can we deploy the Dokuwiki in prod?')
  }
  agent any
  stages {
     stage ('Build and run Docker for Dokuwiki') {
	    when {
	     expression {params.build_and_run_docker == true}
	    }  
	      stages {
          stage('Cloning Git') {
            steps {
              git url: "${params.repository_url}"
            }
          }
          stage('Building image') {
            steps {
              script {
                dockerImage = docker.build registry + ":$BUILD_NUMBER"
              }
            }
          }	          
          stage('Deploy Image') {
            steps {
              script {
                docker.withRegistry( '', registryCredential ) {
                  dockerImage.push()
                }
              }
            }
          }
          stage('Run Docker image'){
            steps {
              sh "echo $registry:$BUILD_NUMBER"
              sh "docker run -d  -p 4000:80 --name dokuwiki $registry:$BUILD_NUMBER"
            }
          }  
	      }
     }
     stage('Deploy Dokuwiki in prod') {
	    when {
	     expression {params.deploy_in_prod == true}
	    }
        stages {
		      stage('Kill and delete Docker container') {
		        steps {
              sh "docker container stop dokuwiki"
			        sh "docker container prune -f"
	          }
		      }
          stage('Remove Unused docker image') {
            steps{
              sh "docker system prune -af"
            }
          }
		      stage ('Play ansible to deploy  in prod') {
	          steps {
	            sh "ansible-playbook play.yaml -i inventory/main.yaml --vault-password-file vault_pass"
	          }
		      }	  
		      stage ('Test Dokuwiki') {
		        steps {
		          sh "curl http://wiki.project"
            }
		      }
        }
     }		
   }
  post {
    success {
      slackSend (color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
      }
    failure {
      slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
      }
    }
}