# Licensed to the University Corporation for Advanced Internet Development,
# Inc. (UCAID) under one or more contributor license agreements.  See the
# NOTICE file distributed with this work for additional information regarding
# copyright ownership. The UCAID licenses this file to You under the Apache
# License, Version 2.0 (the "License"); you may not use this file except in
# compliance with the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
// Licensed to the University Corporation for Advanced Internet Development,
// Inc. (UCAID) under one or more contributor license agreements.  See the
// NOTICE file distributed with this work for additional information regarding
// copyright ownership. The UCAID licenses this file to You under the Apache
// License, Version 2.0 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
# Licensed to the University Corporation for Advanced Internet Development,
# Inc. (UCAID) under one or more contributor license agreements.  See the
# NOTICE file distributed with this work for additional information regarding
# copyright ownership. The UCAID licenses this file to You under the Apache
# License, Version 2.0 (the "License"); you may not use this file except in
# compliance with the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Licensed to the University Corporation for Advanced Internet Development,
# Inc. (UCAID) under one or more contributor license agreements.  See the
# NOTICE file distributed with this work for additional information regarding
# copyright ownership. The UCAID licenses this file to You under the Apache
# License, Version 2.0 (the "License"); you may not use this file except in
# compliance with the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
node('docker') {

  stage 'Checkout'

    checkout scm

  stage 'Acquire util'

    sh 'mkdir -p tmp'
    dir('tmp'){
      git([ url: "https://github.internet2.edu/docker/util.git",
          credentialsId: "jenkins-github-access-token" ])
      sh 'ls'
      sh 'mv bin/* ../bin/.'
    }
  stage 'Setting build context'
  
    def maintainer = maintainer()
    def imagename = imagename()
    def tag
    
    // Tag images created on master branch with 'latest'
    if(env.BRANCH_NAME == "master"){
      tag = "latest"
    }else{
      tag = env.BRANCH_NAME
    }
        
    if(!imagename){
      echo "You must define an imagename in common.bash"
      currentBuild.result = 'FAILURE'
     }
     if(maintainer){
      echo "Building ${imagename}:${tag} for ${maintainer}"
     }

  stage 'Build'
    try{
      sh 'bin/rebuild.sh &> debug'
    } catch(error) {
      def error_details = readFile('./debug');
      def message = "BUILD ERROR: There was a problem building the shibboleth-sp mage. \n\n ${error_details}"
      sh "rm -f ./debug"
      handleError(message)
    }
  stage 'Start container'

    sh 'bin/ci-run.sh'

  stage 'Tests'

    try{
      sh 'bin/test.sh &> debug'
    } catch(error) {
      def error_details = readFile('./debug');
      def message = "BUILD ERROR: There was a problem testing ${imagename}:${tag}. \n\n ${error_details}"
      sh "rm -f ./debug"
      handleError(message)
    }
    
  stage 'Stop container'

    sh 'bin/ci-stop.sh'

  stage 'Push'
    docker.withRegistry('https://registry.hub.docker.com/',   "dockerhub-$maintainer") {
          def baseImg = docker.build("$maintainer/$imagename")
          baseImg.push("$tag")
    }
    
  stage 'Notify'
  
    slackSend color: 'good', message: "$maintainer/$imagename:$tag pushed to DockerHub"
}

def maintainer() {
  def matcher = readFile('common.bash') =~ 'maintainer="(.+)"'
  matcher ? matcher[0][1] : 'tier'
}

def imagename() {
  def matcher = readFile('common.bash') =~ 'imagename="(.+)"'
  matcher ? matcher[0][1] : null
}

def handleError(String message){
  echo "${message}"
  currentBuild.setResult("FAILED")
  slackSend color: 'danger', message: "${message}"
  sh 'exit 1'
}
