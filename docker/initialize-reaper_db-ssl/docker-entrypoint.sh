#!/usr/bin/env bash

set -xe

REPLICATION_FACTOR=$1

# convert reaper's key store into the PKCS format
keytool -importkeystore -srckeystore /etc/ssl/reaper-server-keystore.jks -destkeystore /etc/ssl/reaper.p12 \
    -deststoretype PKCS12 -srcstorepass keypassword -deststorepass keypassword -srcalias reaper -destalias reaper

# extract key and cert from the PKCS and place them in heir own files
openssl pkcs12 -in /etc/ssl/reaper.p12 -nokeys -out /etc/ssl/cql.cer.pem -passin pass:keypassword
openssl pkcs12 -in /etc/ssl/reaper.p12 -nocerts -nodes -out /etc/ssl/cql.key.pem -passin pass:keypassword

# make cqlsh expect the generated key and cert files
echo "
[authentication]
username = reaper
password = keypassword

[connection]
factory = cqlshlib.ssl.ssl_transport_factory

[ssl]
certfile = /etc/ssl/ca-cert
validate = true
userkey = /etc/ssl/cql.key.pem
usercert = /etc/ssl/cql.cer.pem
" > .cqlshrc

# run cqlsh with ssl enabled
cqlsh cassandra-ssl --cqlshrc .cqlshrc --ssl -e \
    "CREATE KEYSPACE IF NOT EXISTS reaper_db \
    WITH replication = {'class': 'SimpleStrategy', \
                        'replication_factor': $REPLICATION_FACTOR };"
