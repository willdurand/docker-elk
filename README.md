Elasticsearch. Logstash. Kibana.
================================

Creating an ELK stack could not be easier.

Usage
-----

```
$ docker run -p 8080:80 \
    -v /path/to/your/logstash/config:/etc/logstash \
    willdurand/elk
```

Then, browse: [http://localhost:8080](http://localhost:8080) (replace
`localhost` with your public IP address).

Your logstash configuration directory MUST contain a `logstash.conf` file.

### Fig Configuration

``` yaml
elk:
  image: willdurand/elk
  ports:
    - "8080:80"
  volumes:
    - /path/to/your/logstash/config:/etc/logstash
```

Data
----

Elasticsearch data are located in the `/srv/data` directory. It is probably a
good idea to mount a volume in order to preserve data integrity. You can create
a _data only container_:

```
$ docker run -d -v /srv/data --name dataelk busybox
```

Then, use it:

```
$ docker run -p 8080:80 \
    -v /path/to/your/logstash/config:/etc/logstash \
    --volumes-from dataelk \
    willdurand/elk
```

If you want to rely on the logstash agent for processing files, you have to
mount volumes as well.

### Fig Configuration

``` yaml
elk:
  image: willdurand/elk
  ports:
    - "8080:80"
  volumes:
    - /path/to/your/logstash/config:/etc/logstash
  volumes_from:
    - dataelk
```

Logging
-------

Logs are directly written into the container, but those directories are declared
as volumes:

* Elasticsearch: `/var/log/elasticsearch`
* Logstash: `/var/log/logstash`
* Nginx: `/var/log/nginx`
