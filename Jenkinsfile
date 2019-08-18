pipeline {
  environment {
    registry = "apovyshev/devops_docker"
    registryCredential = 'dockerhub'
  }
  parameters {
    string(name: 'repository_url', defaultValue: 'git@github.com:pluhin/sa.it-academy.by.git', description: 'Github repository url')
    booleanParam(name: 'build_and_run_docker', defaultValue: true, description: 'Deploy and run Docker for tests')
	booleanParam(name: 'deploy_in_prod', defaultValue: false, description: 'Can we deploy the Postleaf in prod?')
  }
  agent any
  stages {
    stage ('Build and run Docker for Postleaf v.alpha-4') {
	  when {
	    expression {params.build_and_run_docker == true}
	  }
	  stages {
        stage('Cloning Git') {
          steps {
            git url: "${params.repository_url}"
          }
        }
	    stage('Change into postleaf-docker directory') {
	      steps {
	        sh "cd postleaf-docker"
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
            sh "mkdir -R html/{data,cache,uploads}"
		    sh "sudo chown -R vagrant:vagrant $(pwd)/html"
		    sh "echo $registry:$BUILD_NUMBER"
            sh "docker run -tid -v $(pwd)/html/data:/usr/share/nginx/html/data -v $(pwd)/html/cache:/usr/share/nginx/html/cache -v $(pwd)/html/uploads:/usr/share/nginx/html/uploads -p 80:80 --name postleaf $registry:$BUILD_NUMBER"
          }
        }  
	  }
	}
	stage('Deploy Postleaf v.alpha-4 in prod') {
	  when {
	    expression {params.deploy_in_prod == true}
	  }
      stages {
		stage('Kill and delete Docker container') {
		  steps {
			sh "docker stop $(docker ps -a -q)"
			sh "docker rm -f $(docker ps -a -q)"
	      }
		}
        stage('Remove Unused docker image') {
          steps{
            sh "docker rmi $(docker images -a -q)"
          }
        }
        stage('Change into postleaf-docker directory') {
	      steps {
	        sh "cd postleaf-docker"
		  }
	    }		
		stage ('Play ansible to deploy Postleaf in prod') {
	      steps {
	        sh "ansible-playbook $(pwd)/play.yaml -i $(pwd)/inventory/main.yaml --vault-password-file $(pwd)/vault_pass"
	      }
		}	  
		stage ('Test Postleaf') {
		  steps {
		    sh "curl http://postleaf.project"
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
