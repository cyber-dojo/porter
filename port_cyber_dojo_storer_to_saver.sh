#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly MY_NAME=`basename "${0}"`

echo "${MY_NAME} ${1} ... sdfsdf"

# lots of help/use text
# recommend starting with few id10, then few id2
# have option to generate id2/id10 inside storer
# (means it must not be an exception to try and port
# an id that has already been ported)

# check docker installed

# check data-container exists
# check storer service is NOT already up
# docker pull cyberdojo/storer (to get eg kata_delete)
# bring up storer service

# docker pull cyberdojo/saver
# make sure /cyber-dojo dir exists
# bring up saver service and volume-mount /cyber-dojo dir
# check saver-uid has write access to /cyber-dojo (with docker exec)
#    (if on DockerToolbox with will be on default VM)

# docker pull cyberdojo/porter
# make sure /id-map exists (??? OR PUT JSON FILES IN /tmp ???)
# bring up porter container - needs to link to storer and saver
# check porter-uid has write access to /id-map (with docker exec)
#    (if on DockerToolbox with will be on default VM)
# docker exec -it porter-container sh -c 'ruby /app/port.rb ${*}'

# always remove porter container
# always remove saver container
