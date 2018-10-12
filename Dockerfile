FROM centos:centos7

# Define args and set a default value
ARG maintainer=tier
ARG imagename=shibboleth_sp
ARG version=3.0.2

MAINTAINER $maintainer
LABEL Vendor="Internet2"
LABEL ImageType="Base"
LABEL ImageName=$imagename
LABEL ImageOS=centos7
LABEL Version=$version

LABEL Build docker build --rm --tag $maintainer/$imagename .

ADD ./container_files/bin/httpd-shib-foreground  /usr/local/bin/
ADD ./container_files/bin/shibboleth_keygen.sh  /usr/local/bin/
ADD ./container_files/etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ 


RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
    && echo "NETWORKING=yes" > /etc/sysconfig/network

RUN rm -fr /var/cache/yum/* && yum clean all && yum -y install --setopt=tsflags=nodocs epel-release && yum -y update && \
    yum -y install net-tools wget curl tar unzip mlocate logrotate strace telnet man vim rsyslog cron httpd mod_ssl dos2unix && \
    yum clean all

RUN curl -o /etc/yum.repos.d/security:shibboleth.repo \
      http://download.opensuse.org/repositories/security://shibboleth/CentOS_7/security:shibboleth.repo \
      && yum -y install shibboleth.x86_64 \
      && yum clean all \
      && rm /etc/httpd/conf.d/autoindex.conf \
      && rm /etc/httpd/conf.d/userdir.conf \
      && rm /etc/httpd/conf.d/welcome.conf \
      && chmod +x /usr/local/bin/httpd-shib-foreground \
      && chmod +x /usr/local/bin/shibboleth_keygen.sh
      
# Export this variable so that shibd can find its CURL library
RUN LD_LIBRARY_PATH="/opt/shibboleth/lib64"
RUN export LD_LIBRARY_PATH

# fix shibd.logger, other?.logger

# fix httpd logging to tier format


EXPOSE 80 443
CMD ["httpd-shib-foreground"]


