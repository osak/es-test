#!/bin/bash

set -ex

docker run -d --network es-test-net --name es01 -it -p 9200:9200 -m 4GB es-test 
exec docker logs -f es01
