#!/bin/bash

docker run -p 5601:5601 -d --name kibana --network es-test-net \
    -e ELASTICSEARCH_URL=http://es01:9200 \
    -e ELASTICSEARCH_HOSTS=http://es01:9200 \
    -e 'xpack.security.enabled=false' \
    -e 'xpack.license.self_generated.type=basic' \
    docker.elastic.co/kibana/kibana:8.14.3
