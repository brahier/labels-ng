#!/bin/bash
docker run -ti --rm -v ${PWD}:/data brahier/docker-label-ng /bin/bash -c "cd /data; ./parse-3.pl $1"
