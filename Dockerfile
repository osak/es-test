FROM docker.elastic.co/elasticsearch/elasticsearch:8.14.3

COPY elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
