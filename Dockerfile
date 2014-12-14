FROM dockerfile/java:oracle-java8
MAINTAINER William Durand <william.durand1@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y supervisor

# Elasticsearch
RUN \
	wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    if ! grep "elasticsearch" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main" >> /etc/apt/sources.list;fi && \
    if ! grep "logstash" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/logstash/1.4/debian stable main" >> /etc/apt/sources.list;fi && \
    apt-get update

RUN \
	apt-get install -y elasticsearch && \
    sed -i '/#cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml && \
    sed -i '/#path.data: \/path\/to\/data/a path.data: /data' /etc/elasticsearch/elasticsearch.yml

ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf

# Logstash
RUN apt-get install -y logstash

ADD etc/supervisor/conf.d/logstash.conf /etc/supervisor/conf.d/logstash.conf

# Kibana
RUN \
    apt-get install -y nginx && \
	if ! grep "daemon off" /etc/nginx/nginx.conf; then sed -i '/worker_processes.*/a daemon off;' /etc/nginx/nginx.conf;fi && \
	mkdir -p /var/www && \
	wget -O kibana.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz && \
    tar xzf kibana.tar.gz -C /opt && \
    ln -s /opt/kibana-3.1.0 /var/www/kibana

RUN sed -i 's/"http:\/\/"+window.location.hostname+":9200"/"http:\/\/"+window.location.hostname+":"+window.location.port/' /opt/kibana-3.1.0/config.js

# configure nginx
ADD etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default

VOLUME [ "/data" ]

EXPOSE 80

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
