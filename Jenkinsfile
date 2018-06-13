pipeline {
    agent { dockerfile true }
    environment {
        NOTIF_TOKEN = credentials('dp-hipchat-token')
        ROOM_ID = "4463087"
    }
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    parameters {
        choice(choices: 'Apply\nDestroy', description:  'Terraform function', name: 'terraform_function')
        choice(choices: 'DEV\nQA\nUAT\nPROD', description:  'Deploy Scenario', name: 'deploy_scenario')
        string(defaultValue: 'std', description: 'Stack Aggregation Tag', name: 'stack_aggregation')
    }
    stages {
        stage('Init') {
            steps {
                script {
                    def props = readProperties  file:'terraform.tfvars'
                    env.PROD_KEY = props['product_key']
                    env.APPLICATION_NAME = props['application_name']
                    env.TF_CONTAINER_NAME = "${env.PROD_KEY.toLowerCase()}-${env.APPLICATION_NAME.toLowerCase()}"

                    env.TF_DESTROY_SWITCH = (params.terraform_function == "Apply") ? "" : "-destroy"

                    if(params.deploy_scenario == 'PROD') {
                        env.CREDENTIALS = 'Azure_Prod_SPN'
                        env.BACKEND_CONFIG_ID = "terraform_backend_config-PROD"
                    } else {
                        env.CREDENTIALS = 'Azure_NonProd_SPN'
                        env.BACKEND_CONFIG_ID = "terraform_backend_config-NonPROD"
                    }
                }
                //Send message to hipchat on start
                hipchatSend (color: 'YELLOW', notify: true, room: "${ROOM_ID}", token: "${NOTIF_TOKEN}", message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
                configFileProvider([configFile(fileId: env.BACKEND_CONFIG_ID, targetLocation: './backend.tf')]) {
                  withCredentials([azureServicePrincipal(env.CREDENTIALS)]) {
                      // TODO: Figure out why .terraform/ folders are bing injected into the Jenkins Workspace
                      sh "rm -rf .terraform/"
                      sh "terraform init -input=false -backend-config=container_name=${env.TF_CONTAINER_NAME} -backend-config='arm_client_id=${AZURE_CLIENT_ID}' -backend-config='arm_client_secret=${AZURE_CLIENT_SECRET}'"
                  }
                  sh "terraform workspace new ${params.deploy_scenario} || terraform workspace select ${params.deploy_scenario}"
                }
            }
        }
        stage('Plan') {
            steps {
                //Send message to hipchat on start
                hipchatSend (color: 'YELLOW', notify: true, room: "${ROOM_ID}", token: "${NOTIF_TOKEN}", message: "TF PLAN: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
                  withCredentials([azureServicePrincipal(env.CREDENTIALS)]) {
                      sh "terraform plan ${env.TF_DESTROY_SWITCH} -var-file=vars/${params.deploy_scenario}.tfvars -var subscription_id=$AZURE_SUBSCRIPTION_ID -var client_id=$AZURE_CLIENT_ID -var client_secret=$AZURE_CLIENT_SECRET -input=false -out=tfplan"
                  }
            }
        }
        stage('Deploy') {
            when {
                expression { params.terraform_function == 'Apply' }
            }
            steps {
                //Send message to hipchat on start
                input 'Continue to Deployment?'
                hipchatSend (color: 'YELLOW', notify: true, room: "${ROOM_ID}", token: "${NOTIF_TOKEN}", message: "TF DEPLOY: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")

                sh "terraform apply \"tfplan\""
            }
        }
        stage('Destroy') {
            when {
                expression { params.terraform_function == 'Destroy' }
            }
            steps {
                //Send message to hipchat on start
                input 'WARNING: Are you sure you wish to DESTROY these resources?'
                hipchatSend (color: 'YELLOW', notify: true, room: "${ROOM_ID}", token: "${NOTIF_TOKEN}", message: "TF DESTROY: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
                withCredentials([azureServicePrincipal(env.CREDENTIALS)]) {
                    sh "terraform destroy -auto-approve -var-file=vars/${params.deploy_scenario}.tfvars -var subscription_id=$AZURE_SUBSCRIPTION_ID -var client_id=$AZURE_CLIENT_ID -var client_secret=$AZURE_CLIENT_SECRET"
                }
            }
        }
    }
    post {
      success {
        sh "echo SUCCESS"
        //Send message to hipchat on success
        hipchatSend (color: 'GREEN', notify: true, room: "${ROOM_ID}", token: "${NOTIF_TOKEN}", message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
      }
      failure {
        sh "echo FAILURE"
        //Send message to hipchat on failure
        hipchatSend (color: 'RED', notify: true, room: "${ROOM_ID}", token: "${NOTIF_TOKEN}", message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
      }
    }
}
