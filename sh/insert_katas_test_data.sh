#!/bin/bash
set -e

readonly STORER_CONTAINER=test-porter-storer

echo -n "Inserting test-data into ${STORER_CONTAINER}"

docker run \
   --rm \
   -it \
   --volume /var/run/docker.sock:/var/run/docker.sock \
   cyberdojo/inserter \
     ${STORER_CONTAINER} \
       dup_server old new red throws rm_fail
       # 02 4D 7E FD

echo 'OK'
