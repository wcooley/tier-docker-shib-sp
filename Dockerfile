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
      && rm /etc/httpd/conf.d/welcome.conf
      
# Export this variable so that shibd can find its CURL library
RUN LD_LIBRARY_PATH="/opt/shibboleth/lib64"
RUN export LD_LIBRARY_PATH

ADD ./container_files/system/httpd-shib-foreground  /usr/local/bin/
ADD ./container_files/system/shibboleth_keygen.sh  /usr/local/bin/
ADD ./container_files/httpd/ssl.conf /etc/httpd/conf.d/
ADD ./container_files/shibboleth/* /etc/shibboleth/

RUN chmod +x /usr/local/bin/httpd-shib-foreground \
      && chmod +x /usr/local/bin/shibboleth_keygen.sh

# fix httpd logging to tier format
RUN sed -i 's/LogFormat "/LogFormat "httpd;access_log;%{ENV}e;%{USERTOKEN}e;/g' /etc/httpd/conf/httpd.conf \
    && echo -e "\nErrorLogFormat \"httpd;error_log;%{ENV}e;%{USERTOKEN}e;[%{u}t] [%-m:%l] [pid %P:tid %T] %7F: %E: [client\ %a] %M% ,\ referer\ %{Referer}i\"" >> /etc/httpd/conf/httpd.conf \
    && sed -i 's/CustomLog "logs\/access_log"/CustomLog "\/tmp\/logpipe"/g' /etc/httpd/conf/httpd.conf \
    && sed -i 's/ErrorLog "logs\/error_log"/ErrorLog "\/tmp\/logpipe"/g' /etc/httpd/conf/httpd.conf \
    && echo -e "\nPassEnv ENV" >> /etc/httpd/conf/httpd.conf \
    && echo -e "\nPassEnv USERTOKEN" >> /etc/httpd/conf/httpd.conf \
    && sed -i '/UseCanonicalName/c\UseCanonicalName On' /etc/httpd/conf/httpd.conf

# add a basic page to shibb's default protected directory
RUN mkdir -p /var/www/html/secure/
ADD container_files/httpd/index.html /var/www/html/secure/


EXPOSE 80 443
CMD ["httpd-shib-foreground"]


