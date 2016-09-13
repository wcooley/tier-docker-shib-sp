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
      
COPY httpd-shib-foreground /usr/local/bin/
COPY conf/attribute-map.xml /opt/etc/shibboleth/attribute-map.xml
COPY conf/inc-md-cert.pem /opt/etc/shibboleth/inc-md-cert.pem
COPY conf/shibboleth_keygen.sh /opt/bin/shibboleth_keygen.sh

#Added shib module apache
RUN ln -s /opt/etc/httpd/conf.modules.d/00-shib.conf /etc/httpd/conf.modules.d/00-shib.conf
RUN ln -s /usr/lib64/shibboleth/mod_shib_24.so /etc/httpd/modules/mod_shib_24.so

EXPOSE 80 443
CMD ["httpd-shib-foreground"]
