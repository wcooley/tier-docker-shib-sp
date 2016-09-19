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

# Add starters and installers
ADD ./container_files /opt

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
      && rm /etc/httpd/conf.d/welcome.conf \
      && chmod +x /opt/bin/httpd-shib-foreground \
      && chmod +x /opt/bin/shibboleth_keygen.sh

#Script to start service, Added ssl default conf, Added shib module apache
RUN ln -s /opt/bin/httpd-shib-foreground  /usr/local/bin && ln -s /opt/etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf && ln -s /opt/etc/httpd/conf.modules.d/00-shib.conf /etc/httpd/conf.modules.d/00-shib.conf && ln -s /usr/lib64/shibboleth/mod_shib_24.so /etc/httpd/modules/mod_shib_24.so

EXPOSE 80 443
CMD ["httpd-shib-foreground"]
