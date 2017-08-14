FROM cassandra:3.11

ENV WORKDIR /root
WORKDIR ${WORKDIR}
ARG key_store_pwd
ARG trust_store_pwd


# TODO: Remove this SSH installation once container is ready
# setup SSH
RUN set -x \
    && apt-get update \
    && apt-get -y install openssh-server vim \
    && mkdir -p ${WORKDIR}/.ssh \
    && chmod -R 700 ${WORKDIR}/.ssh

COPY authorized_keys ${WORKDIR}/.ssh/authorized_keys
RUN chmod 600 ${WORKDIR}/.ssh/authorized_keys


# Set password for SSL stores used when calling nodetool
COPY nodetool-ssl.properties ${WORKDIR}/.cassandra/nodetool-ssl.properties
RUN sed -ie "s/KEYSTORE_PASSWORD/${key_store_pwd}/g" ${WORKDIR}/.cassandra/nodetool-ssl.properties \
    && sed -ie "s/TRUSTSTORE_PASSWORD/${trust_store_pwd}/g" ${WORKDIR}/.cassandra/nodetool-ssl.properties

# Set JVM SSL encryption options for Cassandra
RUN sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=true"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=true"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.need.client.auth=true"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.need.client.auth=true"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.protocols=<enabled-protocols>"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.cipher.suites=<enabled-cipher-suites>"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.cipher.suites=TLS_RSA_WITH_AES_256_CBC_SHA"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStore=\/path\/to\/keystore\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStore=\/etc\/ssl\/node-server-keystore\.jks\"/g" /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStorePassword=<keystore-password>\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStorePassword=${key_store_pwd}\"/g" /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStore=\/path\/to\/truststore\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStore=\/etc\/ssl\/generic-server-truststore\.jks\"/g" /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStorePassword=<truststore-password>\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStorePassword=${trust_store_pwd}\"/g" /etc/cassandra/cassandra-env.sh \
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