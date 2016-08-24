#!/usr/bin/env bats

load ../common

@test "Shibd binary available" {
  docker run -i $maintainer/$imagename find /usr/sbin/shibd
}

@test "Shibboleth root available" {
  docker run -i $maintainer/$imagename find /etc/shibboleth
}