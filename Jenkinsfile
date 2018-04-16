pipeline {
    agent any
    stages {
        stage ('Checkout') {
            options {
                // Don't checkout the repo where it is this Jenkinsfles, just the target repos of this pipeline. Must be set at every stage.
                skipDefaultCheckout true
            }
            parallel {
                stage('Checkout vdc-logging') {
                    options { skipDefaultCheckout true }
                    steps {
                        dir('vdc-logging') {
                            git changelog: false, credentialsId: 'Aitor-IDEKO-GitHub', poll: false, url: 'https://github.com/DITAS-Project/VDC-Logging-Agent.git'
                        }
                    }
                }
                stage('Checkout vdc-request') {
                    options { skipDefaultCheckout true }
                    steps {
                        dir('vdc-request') {
                            git changelog: false, credentialsId: 'Aitor-IDEKO-GitHub', poll: false, url: 'https://github.com/DITAS-Project/VDC-Request-Monitor.git'
                        }
                    }
                }
                stage('Checkout vdc-throughput') {
                    options { skipDefaultCheckout true }
                    steps {
                        dir('vdc-throughput') {
                            git changelog: false, credentialsId: 'Aitor-IDEKO-GitHub', poll: false, url: 'https://github.com/DITAS-Project/VDC-Throughput-Agent.git'
                        }
                    }
                }
            }
        }
        stage ('Build - Test') {
            parallel {
                stage('Build - test vdc-logging') {
                    agent {
                        dockerfile {
                            filename 'golang:1.10.1'
                        }
                    }
                    steps {
                        dir('vdc-logging') {
                           go get -u 'github.com/golang/dep/cmd/dep'
                           dep ensure
                           go test ./...
                        }
                    }
                }
                stage('Checkout vdc-throughput') {
                    agent {
                        dockerfile {
                            filename 'maven:3-jdk-8'
                        }
                    }
                    steps {
                        apt-get update
                        apt-get install -y iptraf-ng
                        dir('vdc-throughput') {
                            mvm test
                        }
                    }
                }
                stage('Checkout vdc-request') {
                    //build the base image somehow?
                    //build the test enviroment
                    agent {
                        dockerfile {
                            filename 'Dockerfile.vdc-request.build'
                        }
                    }
                    steps {
                        sh test.sh
                    }
                }
                
            }
        }
        // If we reach this stage, the building and testing stages has been finished sucesfully.
        // Now we trust the code so we can build the final docker image
        stage ('Image generation') {
            // The final image must be built at the node itsefl, not inside a container
            agent any
            options {
                skipDefaultCheckout true
            }
            steps {
               // The Dockerfile.artifact copies the code into the image and run the jar generation.
               echo 'Creating the image...'

               // This will search for a Dockerfile.artifact in the working directory and build the image to the local repository
               sh "docker build -t \"ditas/vdc-base-image\" -f Dockerfile.artifact ."
               echo "Done"

               echo 'Retrieving Docker Hub password from /opt/ditas-docker-hub.passwd...'
               // Get the password from a file. This reads the file from the host, not the container. Slaves already have the password in there.
               script {
                   password = readFile '/opt/ditas-docker-hub.passwd'
               }
               echo "Done"

               echo 'Login to Docker Hub as ditasgeneric...'
               sh "docker login -u ditasgeneric -p ${password}"
               echo "Done"

               echo "Pushing the image ditas/vdc-base-image:latest..."
               sh "docker push ditas/vdc-base-image:latest"
               echo "Done "
           }
        }
        // Deploy the image to the staging seerver
        stage('Image deploy') {
            agent any
            options {
                // Don't need to checkout Git again
                skipDefaultCheckout true
            }
            steps {
                // Deploy to Staging environment calling the deployment script
                // !!!! Edit this file to set the correct iamge tag
                sh './jenkins/deploy-staging.sh'
            }
        }
    }
}
