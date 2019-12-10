FROM ubuntu:latest
LABEL maintainer quanghd96
# Using instructions from
# https://www.digitalocean.com/community/tutorials/how-to-install-prometheus-on-ubuntu-16-04

ENV PROMETHEUS_VER v2.14.0
ENV PROMETHEUS_TAR prometheus-2.14.0.linux-amd64.tar.gz
ENV PROMETHEUS_TAR_FOLDER prometheus-2.14.0.linux-amd64

ENV REFRESHED_AT 2019-11-11
ENV DEBIAN_FRONTEND noninteractive

# Update packages, install apache, free diskspace
RUN apt-get -yqq update && \
    apt-get -yqq upgrade && \
    apt-get -yqq install curl && \
    apt-get -yqq install nano && \
    apt-get -yqq install supervisor && \
    rm -rf /var/lib/apt/lists/*

# Create User
# RUN useradd --no-create-home --shell /bin/false prometheus

# Create Folders
RUN mkdir /etc/prometheus
RUN mkdir /var/lib/prometheus
RUN mkdir /opt/prometheus

# Set User Rights
# RUN chown prometheus:prometheus /etc/prometheus
# RUN chown prometheus:prometheus /var/lib/prometheus

# Download and extract prometheus sourcen
RUN mkdir -p /tmp/prometheus && \
    cd /tmp/prometheus/ && \
    curl -LO https://github.com/prometheus/prometheus/releases/download/${PROMETHEUS_VER}/${PROMETHEUS_TAR} && \
    tar xvf ${PROMETHEUS_TAR} && \
    cp ${PROMETHEUS_TAR_FOLDER}/prometheus /usr/local/bin/ && \
    cp ${PROMETHEUS_TAR_FOLDER}/promtool /usr/local/bin/ && \
    cp -r ${PROMETHEUS_TAR_FOLDER}/consoles /etc/prometheus && \
    cp -r ${PROMETHEUS_TAR_FOLDER}/console_libraries /etc/prometheus && \
    rm -rf /tmp/prometheus
    
# Again Set User Rights
# RUN chown prometheus:prometheus /usr/local/bin/prometheus
# RUN chown prometheus:prometheus /usr/local/bin/promtool
# RUN chown -R prometheus:prometheus /etc/prometheus/consoles
# RUN chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Copy prometheus.yml into container
COPY prometheus.yml /opt/prometheus/prometheus.yml

# Again Set User Rights
# RUN chown prometheus:prometheus /tmp/prometheus.yml.sample

# Copy helper scripts into container
COPY docker-entrypoint.sh /tmp/
RUN chmod 777 /tmp/docker-entrypoint.sh
COPY supervisor_prometheus.conf /tmp/

#
EXPOSE 9090

VOLUME /var/log/supervisor
VOLUME /var/lib/prometheus
VOLUME /opt/prometheus

# run shell to keep container alive for testing
# CMD  /bin/bash

# Start prometheus directly
# ENTRYPOINT [ "/usr/local/bin/prometheus" ]
# CMD        [ "--config.file=/opt/prometheus/prometheus.yml", \
#              "--storage.tsdb.path=/var/lib/prometheus/", \
#              "--web.console.libraries=/etc/prometheus/console_libraries", \
#              "--web.console.templates=/etc/prometheus/consoles" ]
             
# Start prometheus using supervisor (useful later to start other apps like node exporter)
CMD ["/tmp/docker-entrypoint.sh"]
