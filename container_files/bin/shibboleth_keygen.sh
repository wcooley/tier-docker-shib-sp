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
#! /bin/sh

while getopts h:u:g:o:e:y:bf c
     do
         case $c in
           o)         OUT=$OPTARG;;
           b)         BATCH=1;;
           f)         FORCE=1;;
           h)         FQDN=$OPTARG;;
           e)         ENTITYID=$OPTARG;;
           y)         YEARS=$OPTARG;;
           \?)        echo "shibboleth_keygen [-o output directory (default .)] [-h hostname for cert] [-y years to issue cert] [-e entityID to embed in cert]"
                      exit 1;;
         esac
     done
if [ -z "$OUT" ] ; then
    OUT=.
fi

if [ -n "$FORCE" ] ; then
    rm $OUT/sp-key.pem $OUT/sp-cert.pem
fi

if  [ -s $OUT/sp-key.pem -o -s $OUT/sp-cert.pem ] ; then
    if [ -z "$BATCH" ] ; then  
        echo The files $OUT/sp-key.pem and/or $OUT/sp-cert.pem already exist!
        echo Use -f option to force recreation of keypair.
        exit 2
    fi
    exit 0
fi

if [ -z "$FQDN" ] ; then
    FQDN=`hostname --fqdn`
fi

if [ -z "$YEARS" ] ; then
    YEARS=10
fi

DAYS=`expr $YEARS \* 365`

if [ -z "$ENTITYID" ] ; then
    ALTNAME=DNS:$FQDN
else
    ALTNAME=DNS:$FQDN,URI:$ENTITYID
fi

SSLCNF=$OUT/sp-cert.cnf
cat >$SSLCNF <<EOF
# OpenSSL configuration file for creating sp-cert.pem
[req]
prompt=no
default_bits=2048
encrypt_key=no
default_md=sha1
distinguished_name=dn
# PrintableStrings only
string_mask=MASK:0002
x509_extensions=ext
[dn]
CN=$FQDN
[ext]
subjectAltName=$ALTNAME
subjectKeyIdentifier=hash
EOF

touch $OUT/sp-key.pem
chmod 600 $OUT/sp-key.pem
if [ -z "$BATCH" ] ; then
    openssl req -config $SSLCNF -new -x509 -days $DAYS -keyout $OUT/sp-key.pem -out $OUT/sp-cert.pem
else
    openssl req -config $SSLCNF -new -x509 -days $DAYS -keyout $OUT/sp-key.pem -out $OUT/sp-cert.pem 2> /dev/null
fi
rm $SSLCNF
