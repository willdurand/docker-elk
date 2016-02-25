FROM java:8
MAINTAINER William Durand <william.durand1@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y supervisor curl && \
    apt-get clean

# Elasticsearch
RUN \
    apt-key adv --keyserver pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4 && \
    if ! grep "elasticsearch" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main" >> /etc/apt/sources.list;fi && \
    if ! grep "logstash" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/logstash/1.5/debian stable main" >> /etc/apt/sources.list;fi && \
    apt-get update && \
    apt-get install --no-install-recommends -y elasticsearch && \
    apt-get clean && \
    sed -i '/#cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml && \
    sed -i '/#path.data: \/path\/to\/data/a path.data: /data' /etc/elasticsearch/elasticsearch.yml

ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf

# Logstash
RUN apt-get install --no-install-recommends -y logstash && \
    apt-get clean

ADD etc/supervisor/conf.d/logstash.conf /etc/supervisor/conf.d/logstash.conf

# Logstash plugins
RUN /opt/logstash/bin/plugin install logstash-filter-translate

# Kibana
RUN \
    curl -s https://download.elasticsearch.org/kibana/kibana/kibana-4.1.2-linux-x64.tar.gz | tar -C /opt -xz && \
    ln -s /opt/kibana-4.1.2-linux-x64 /opt/kibana && \
    sed -i 's/port: 5601/port: 80/' /opt/kibana/config/kibana.yml

ADD etc/supervisor/conf.d/kibana.conf /etc/supervisor/conf.d/kibana.conf

EXPOSE 80

ENV PATH /opt/logstash/bin:$PATH

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]

