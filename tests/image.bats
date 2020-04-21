#!/usr/bin/env bats

load ../common

@test "Shibd binary available" {
  docker run -i $maintainer/$imagename find /usr/sbin/shibd
}

@test "Shibboleth root available" {
  docker run -i $maintainer/$imagename find /etc/shibboleth
}

@test "Sample attribute map available" {
  docker run -i $maintainer/$imagename find /etc/shibboleth/attribute-map.xml
}

@test "Includes InCommon cert" {
  docker run -i $maintainer/$imagename find /etc/shibboleth/inc-md-cert.pem
}

@test "Includes startup script" {
  docker run -i $maintainer/$imagename find /usr/local/bin/startup.sh
}

#@test "070 There are no known security vulnerabilities" {
#    ./tests/clairscan.sh ${maintainer}/${imagename}:latest
#}

