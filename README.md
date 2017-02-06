Elasticsearch. Logstash. Kibana.
================================

Creating an ELK stack could not be easier.

**Important:**

* The `master` branch (image: `willdurand/elk:latest` or
  `willdurand/elk:kibana-4.1.2`) currently contains an image with Kibana 4.1.2,
  Elasticsearch 1.x, and Logstash 1.x;
* Branch
  [`kibana-4.4.2`](https://github.com/willdurand/docker-elk/tree/kibana-4.4.2)
  (image: `willdurand/elk:kibana-4.4.2`) provides Kibana 4.4.2, Elasticsearch
  2.2, and Logstash 2.2;
* Branch
  [`kibana-4.5.4`](https://github.com/willdurand/docker-elk/tree/kibana-4.5.4)
  (image: `willdurand/elk:kibana-4.5.4`) provides Kibana 4.5.4, Elasticsearch
  2.3, and Logstash 2.3;
* Branch
  [`kibana-5.x`](https://github.com/willdurand/docker-elk/tree/kibana-5.x)
  (image: `willdurand/elk:kibana-5.x`) provides Kibana 5.x, Elasticsearch
  5.x, and Logstash 5.x.


Quick Start
-----------

```
$ docker run -p 8080:80 \
    -v /path/to/your/logstash/config:/etc/logstash \
    willdurand/elk
```

Then, browse: [http://localhost:8080](http://localhost:8080) (replace
`localhost` with your public IP address).

Your logstash configuration directory MUST contain at least one logstash
configuration file. If several files are found in the configuration directory,
logstash will use all of them, concatenated in lexicographical order, as the
configuration.

### Compose Configuration

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

Elasticsearch data are located in the `/data` folder. It is probably a good idea
to mount a volume in order to preserve data integrity. You can create a _data
only container_:

```
$ docker run -d -v /data --name dataelk busybox
```

Then, use it:

```
$ docker run -p 8080:80 \
    -v /path/to/your/logstash/config:/etc/logstash \
    --volumes-from dataelk \
    willdurand/elk
```

If you want to rely on the logstash agent for processing files, you have to
mount volumes as well, but you should rather only send logs to this container.

### Compose Configuration

``` yaml
elk:
    image: willdurand/elk
    ports:
        - "8080:80"
    volumes:
        - /path/to/your/logstash/config:/etc/logstash
    volumes_from:
        - dataelk

dataelk:
    image: busybox
    volumes:
        - /data
```


Real Life Use Case
------------------

You can use this image to run an ELK stack that receives logs from your
production servers, using [Logstash
Forwarder](https://github.com/willdurand/docker-logstash-forwarder):

``` yaml
elk:
    image: willdurand/elk
    ports:
        - "80:80"
        - "XX.XX.XX.XX:5043:5043"
    volumes:
        - /path/to/your/ssl/files:/etc/ssl
        - /path/to/your/logstash/config:/etc/logstash
    volumes_from:
        - dataelk

dataelk:
    image: busybox
    volumes:
        - /data
```

Note that the `5043` port is binded to a private IP address in this case, which
is recommended. Kibana is publicly available though.

Your `logstash` configuration SHOULD contain the following `input` definition:

```
input {
  lumberjack {
    port => 5043
    ssl_certificate => "/etc/ssl/logstash-forwarder.crt"
    ssl_key => "/etc/ssl/logstash-forwarder.key"
  }
}
```


Extend It
---------

One of the Docker best practices is to avoid mapping a host folder to a
container volume. Instead of specifying a volume, it is recommended to use this
image as base image and configure your own image.
