#!/usr/bin/env bats
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

load ../common

@test "Shibd binary available" {
  docker run -i $maintainer/$imagename find /usr/sbin/shibd
}

@test "Shibboleth root available" {
  docker run -i $maintainer/$imagename find /etc/shibboleth
}

@test "Sample attribute map available" {
  docker run -i $maintainer/$imagename find /opt/etc/shibboleth/attribute-map.xml
}

@test "Includes InCommon cert" {
  docker run -i $maintainer/$imagename find /opt/etc/shibboleth/inc-md-cert.pem
}

@test "Includes Shibboleth keygenerator" {
  docker run -i $maintainer/$imagename find /opt/bin/shibboleth_keygen.sh
}
