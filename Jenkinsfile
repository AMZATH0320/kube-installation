pipeline {
    agent any      

    
    environment {
         DOCKER_REPO = 'amzath0304/task' 
         def branchName = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
         env.BRANCH_NAME = branchName
         def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()




    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    
                    echo "Current Workspace: ${pwd()}"
                    // Clone the GitHub repository
                    git branch: 'master', url: 'https://github.com/AMZATH0320/task.git'
                }
            }    
        }

        stage('Login to Dockerhub') {
            steps {
                 withCredentials([usernameColonPassword(credentialsId: 'docker_credential', variable: 'Docker_username_password')]) {
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                  
                   // Get the branch name of the latest commit
                    def branchName = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()

                    // Output the branch name
                    echo "Branch Name of Latest Commit: ${branchName}"

                    // If branchName is null or empty, set to 'unknown'
                    branchName = branchName ?: 'unknown'

                    // Store the branch name for later use
                    env.BRANCH_NAME = branchName

                     // Get the latest commit hash
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()

                    // Set Docker image tags
                    def imageName = "${DOCKER_REPO}:${commitHash}"  // Tag by commit hash
                    def imageTag = "${env.BRANCH_NAME}"  // Tag by branch name

                    // Build the Docker image with two tags (commit hash and branch name)
                    echo "Building Docker image with tags: ${imageName}, ${imageTag}"
                    sh "sudo docker build -t ${imageName}-${imageTag} ."


                    

                   
                }  
            }
        }

        stage('Push docker image') {
            steps {
                script {
                    // Get the latest commit hash and branch name again
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def branchName = env.BRANCH_NAME ?: 'unknown'

                    def imageName = "${DOCKER_REPO}:${commitHash}"
                    def imageTag = "${branchName}"

                    // Push the images to Docker Hub
                    echo "Pushing Docker images to Docker Hub with tags: ${imageName}, ${imageTag}"
                    sh "sudo docker push ${imageName}-${imageTag}"
                }
            }
        }

        stage('Cleanup Docker Images') {
            steps {
                script {
                    // Clean up Docker images and unused resources after pushing
                    sh 'sudo docker system prune -af'
                }
            }
        }
    }
 }
