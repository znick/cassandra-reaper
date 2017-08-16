FROM cassandra:3.11

ENV WORKDIR /root
WORKDIR ${WORKDIR}
ARG KEY_STORE_PWD
ARG TRUST_STORE_PWD


# TODO: Remove this SSH installation once container is ready
# setup SSH
RUN set -x \
    && apt-get update \
    && apt-get -y install openssh-server vim \
    && mkdir -p ${WORKDIR}/.ssh \
    && chmod -R 700 ${WORKDIR}/.ssh

# COPY authorized_keys ${WORKDIR}/.ssh/authorized_keys
# RUN chmod 600 ${WORKDIR}/.ssh/authorized_keys


# Set password for SSL stores used when calling nodetool
COPY nodetool-ssl.properties ${WORKDIR}/.cassandra/nodetool-ssl.properties
RUN sed -ie "s/KEYSTORE_PASSWORD/${KEY_STORE_PWD}/g" ${WORKDIR}/.cassandra/nodetool-ssl.properties \
    && sed -ie "s/TRUSTSTORE_PASSWORD/${TRUST_STORE_PWD}/g" ${WORKDIR}/.cassandra/nodetool-ssl.properties

# Configure cassandra to only accept encrypted native protocol connections
# First delete old config
RUN awk '/client_encryption_options:/{while(getline && $0 != ""){}}1' /etc/cassandra/cassandra.yaml > tmp \
    && mv tmp /etc/cassandra/cassandra.yaml
# Second place new config
RUN echo """client_encryption_options:\n \
    enabled: true\n \
    optional: false\n \
    require_client_auth: true\n \
    keystore: /etc/ssl/node-server-keystore.jks\n \
    keystore_password: ${KEY_STORE_PWD}\n \
    truststore: /etc/ssl/generic-server-truststore.jks\n \
    truststore_password: ${TRUST_STORE_PWD}\n \
    protocol: TLS\n \
    algorithm: SunX509\n \
    store_type: JKS \n \
    cipher_suites: [TLS_RSA_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA]""" >> /etc/cassandra/cassandra.yaml

# Set JVM SSL encryption options for Cassandra
RUN sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=true"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=true"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.need.client.auth=true"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.need.client.auth=true"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.protocols=<enabled-protocols>"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.cipher.suites=<enabled-cipher-suites>"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.cipher.suites=TLS_RSA_WITH_AES_256_CBC_SHA"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStore=\/path\/to\/keystore\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStore=\/etc\/ssl\/node-server-keystore\.jks\"/g" /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStorePassword=<keystore-password>\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStorePassword=${KEY_STORE_PWD}\"/g" /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStore=\/path\/to\/truststore\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStore=\/etc\/ssl\/generic-server-truststore\.jks\"/g" /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStorePassword=<truststore-password>\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStorePassword=${TRUST_STORE_PWD}\"/g" /etc/cassandra/cassandra-env.sh \
    && echo 'JVM_OPTS="$JVM_OPTS -Dcassandra.consistent.rangemovement=false"' >> /etc/cassandra/cassandra-env.sh

# copy entry point
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# 22:   SSH
# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 22 7000 7001 7199 9042 9160
CMD ["cassandra", "-f"]