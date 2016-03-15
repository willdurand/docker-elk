FROM java:8
MAINTAINER William Durand <william.durand1@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV PATH /opt/logstash/bin:$PATH

RUN apt-get update && \
    apt-get install --no-install-recommends -y supervisor curl wget && \
    apt-get clean

# Elasticsearch
RUN \
    wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    rm -f /etc/apt/sources.list.d/* && \
    if ! grep "elasticsearch" /etc/apt/sources.list; then echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" >> /etc/apt/sources.list;fi && \
    if ! grep "logstash" /etc/apt/sources.list; then echo "deb http://packages.elastic.co/logstash/2.2/debian stable main" >> /etc/apt/sources.list;fi && \
    apt-get update && \
    apt-get install --no-install-recommends -y elasticsearch logstash && \
    apt-get clean && \
    sed -i '/# cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml && \
    sed -i '/# path.data: \/path\/to\/data/a path.data: /data' /etc/elasticsearch/elasticsearch.yml && \
    sed -i '/# path.logs: \/path\/to\/logs/a path.logs: /var/log/elasticsearch' /etc/elasticsearch/elasticsearch.yml

# Kibana
RUN \
    curl -s https://download.elasticsearch.org/kibana/kibana/kibana-4.4.2-linux-x64.tar.gz | tar -C /opt -xz && \
    ln -s /opt/kibana-4.4.2-linux-x64 /opt/kibana && \
    sed -i 's/# server\.port: 5601/server.port: 80/' /opt/kibana/config/kibana.yml

# Logstash plugins
RUN /opt/logstash/bin/plugin install logstash-filter-translate

ADD etc/supervisor/conf.d/ /etc/supervisor/conf.d/

RUN mkdir -p /var/log/elasticsearch && \
    mkdir /data && \
    chown elasticsearch:elasticsearch /var/log/elasticsearch && \
    chown elasticsearch:elasticsearch /data

EXPOSE 80

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
