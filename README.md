# shibboleth-sp

[![Build Status](https://jenkins.testbed.tier.internet2.edu/buildStatus/icon?job=docker/shib-sp/master)](https://jenkins.testbed.tier.internet2.edu/job/docker/shib-sp/master)

This is the TIER upstream Shibboleth SP container.

It is based from CentOS 7 and includes httpd, mod_ssl, and the current shibboleth SP.

Files you must supply/override in your downstream builds:

The SP's private key and corresponding certificate (very important!) can be generated in your downstream container like this:
     RUN /usr/local/bin/shibboleth_keygen.sh -o /etc/shibboleth -f
           ...that command generates/overwrites the following files:
                       /etc/shibboleth/sp-key.pem
                       /etc/shibboleth/sp-cert.pem

/etc/httpd/conf.d/ssl.conf
   including:
      ServerName fqdn:port
      UseCanonicalName On

/etc/shibboleth/shibboleth2.xml
   including:
      entityID


