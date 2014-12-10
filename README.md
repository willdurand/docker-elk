Elasticsearch. Logstash. Kibana.
================================

Creating an ELK stack could not be easier.

Usage
-----

```
docker run -p 8080:80 \
    -v /path/to/your/logstash/config:/etc/logstash \
    willdurand/elk
```

Then, browse: [http://localhost:8080](http://localhost:8080) (replace
`localhost` with your public IP address).


Logging
-------

Logs are directly written into the container:

* Elasticsearch: `/var/log/elasticsearch`
* Logstash: `/var/log/logstash`
* Nginx: `/var/log/nginx`
