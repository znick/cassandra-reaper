#!/bin/sh

if [ "$1" = 'cassandra-reaper' ]; then
    set -x
    su-exec reaper /usr/local/bin/append-persistence.sh
    if [ "true" = ${REAPER_CASS_NATIVE_SSL} ]; then
        JAVA_OPTS="${JAVA_OPTS} -Dssl.enable=true \
            -Djavax.net.ssl.trustStore=/etc/ssl/generic-server-truststore.jks \
            -Djavax.net.ssl.trustStorePassword=${REAPER_CASS_SSL_TRUST_PASSWORD} \
            -Djavax.net.ssl.keyStore=/etc/ssl/reaper-server-keystore.jks \
            -Djavax.net.ssl.keyStorePassword=${REAPER_CASS_SSL_KEY_PASSWORD}"
    fi
    exec su-exec reaper java ${JAVA_OPTS} -jar \
        /usr/local/lib/cassandra-reaper.jar server /etc/cassandra-reaper.yml
fi

exec "$@"
