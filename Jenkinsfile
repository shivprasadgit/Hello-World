node{
    try{
   stage('Checkout'){
       checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/shivprasadgit/Hello-World.git']]])
      
   }
     stage('Sonar Analysis'){
        withSonarQubeEnv('SonarCloud'){
            def mvnHome = tool 'maven3.3'
            sh "'${mvnHome}'/bin/mvn sonar:sonar"
            sh 'sleep 1m'
   }
   }
    stage("Quality Gate Result"){
      timeout(time: 15, unit: 'MINUTES') {
      def qg = waitForQualityGate()
      if (qg.status != 'OK') {
         currentBuild.result = "FAILURE"
         error "Pipeline aborted due to quality gate failure: ${qg.status}"
          }
       }
      }
     
      stage("Buid"){
          
          sh 'mvn package -Dmaven.test.skip=true'
          archiveArtifacts 'target/hello-app.war'
      }
      stage("Test"){
          sh 'mvn test'
      }
      stage("Publish Artifacts Nexus"){
          
          nexusPublisher nexusInstanceId: 'Nexus3', nexusRepositoryId: 'maven-releases', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: 'target/hello-app.war']], mavenCoordinate: [artifactId: 'hello-world-war', groupId: 'com.efsavage', packaging: 'war', version: '5.2']]]
          
          
      }
      stage('Docker Image Build'){
	    sh 'docker build -t shivprasad/hello-app:1.0 .'
      }
      stage('Push Docker Image'){
	   withCredentials([string(credentialsId: 'docker-pwd', variable: 'dockerHubPwd')]) {
	      sh "docker login -u shivprasad -p ${dockerHubPwd}"    
	}
      stage('Approval to deploy Prod'){
	    timeout(time: 15, unit: 'MINUTES'){
	    input message: 'Do you approve deployment for production?' , ok: 'Yes'
	    }
	    stage("Deploy Prod"){
	      def dockerRun = "docker container run  -itd -p 8080:8080  --name webapplication shivprasad/hello-app:1.0"
	      sshagent(['dev-server']) {
	      sh "ssh -o StrictHostKeyChecking=no ubuntu@35.228.30.74 ${dockerRun}"
	}
	    
	}
      currentBuild.result = 'SUCCESS'
	}
   catch(err)
  {
    currentBuild.result = 'FAILURE'
    }
  finally{
    mail to:"cloudshiva1000@gmail.com",
             subject: "Status of pipeline: ${currentBuild.fullDisplayName}",
             body: "${env.BUILD_URL} has result ${currentBuild.result} " 
}
}
