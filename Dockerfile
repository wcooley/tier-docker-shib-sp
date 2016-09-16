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
FROM tier/centos7base

# Define args and set a default value
ARG maintainer=tier
ARG imagename=shibboleth_sp
ARG version=2.5.1

MAINTAINER $maintainer
LABEL Vendor="Internet2"
LABEL ImageType="Base"
LABEL ImageName=$imagename
LABEL ImageOS=centos7
LABEL Version=$version

LABEL Build docker build --rm --tag $maintainer/$imagename .

RUN curl -o /etc/yum.repos.d/security:shibboleth.repo \
      http://download.opensuse.org/repositories/security://shibboleth/CentOS_7/security:shibboleth.repo \
      && yum -y update \
      && yum -y install \
        httpd \
        mod_ssl \
        shibboleth.x86_64 \
      && yum clean all \
      && rm /etc/httpd/conf.d/autoindex.conf \
      && rm /etc/httpd/conf.d/ssl.conf \
      && rm /etc/httpd/conf.d/userdir.conf \
      && rm /etc/httpd/conf.d/welcome.conf

# Add starters and installers
ADD ./container_files /opt

#Script to start service, Added ssl default conf, Added shib module apache
RUN ln -s /opt/bin/httpd-shib-foreground  /usr/local/bin && ln -s /opt/etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf && ln -s /opt/etc/httpd/conf.modules.d/00-shib.conf /etc/httpd/conf.modules.d/00-shib.conf && ln -s /usr/lib64/shibboleth/mod_shib_24.so /etc/httpd/modules/mod_shib_24.so

EXPOSE 80 443
CMD ["httpd-shib-foreground"]
