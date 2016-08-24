FROM bigfleet/centos7base

# Define args and set a default value
ARG maintainer=tier
ARG imagename=shibboleth_sp
ARG version=1.0

MAINTAINER $maintainer
LABEL Vendor="Internet2"
LABEL ImageType="Base"
LABEL ImageName=$imagename
LABEL ImageOS=centos7
LABEL Version=$version

LABEL Build docker build --rm --tag $maintainer/$imagename .

RUN curl -o /etc/yum.repos.d/security:shibboleth.repo \
      http://download.opensuse.org/repositories/security://shibboleth/CentOS_7/security:shibboleth.repo \
      && yum -y update && yum -y install shibboleth.x86_64 httpd mod_ssl && yum clean all \
      && rm /etc/httpd/conf.d/autoindex.conf \
      && rm /etc/httpd/conf.d/ssl.conf \
      && rm /etc/httpd/conf.d/userdir.conf \
      && rm /etc/httpd/conf.d/welcome.conf
      
COPY httpd-shib-foreground /usr/local/bin/

EXPOSE 80 443
CMD ["httpd-shib-foreground"]