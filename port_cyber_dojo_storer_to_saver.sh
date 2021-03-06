#!/usr/bin/env bash
set -e

# ensure porter service can see storer/saver services
readonly network_name="port_cyber_dojo_storer_to_saver"
# allow tests to stub the dir saver writes to
readonly saver_host_root_dir="${SAVER_HOST_ROOT_DIR:-/}"
# allow tests to stub the dir porter writes to
readonly porter_host_root_dir="${PORTER_HOST_ROOT_DIR:-/}"
# allow tests to stub the name of storer's data-container
readonly storer_data_container_name="${STORER_DATA_CONTAINER_NAME:-cyber-dojo-katas-DATA-CONTAINER}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_help()
{
  local my_name
  my_name=$(basename "${0}")
  if [ "${1}" = "--help" ] || [ "${1}" = "" ]; then
    cat <<- EOF

  Ports cyber-dojo practice sessions:

                           old-format   --->  new-format
  o) storage medium        data-container     volume-mount
  o) id-length             10                 6
  o) service name          storer             saver
  o) avatar-coupling?      yes                no
  o) individual sessions?  no                 yes

  Please consider backing up your server first.
  Please be patient - initialization takes several seconds.
  Please follow instructions - one-time chown commands will be needed.

  As each session is ported, a single character is printed:
    P - The session has been removed from storer.
        An id mapping was not required.
    M - The session has been removed from storer.
        An id mapping was required.
    e - The session failed to port because an exception arose.
        The session is still in storer.
    a - The session has already been ported.

  Step 1: Pull the latest docker images for the required services:
    \$ docker pull cyberdojo/storer
    \$ docker pull cyberdojo/saver
    \$ docker pull cyberdojo/porter
    \$ docker pull cyberdojo/mapper

  Step 2: Check porting a single session works.
  To show a randomly sampled 10-digit id:
    \$ ./${my_name} --id10
    9f8TeZMZA2
  Then port it:
    \$ ./${my_name} --id10 9f8TeZMZA2
    P

  Step 3: Check porting a batch of sessions works.
  To show a randomly sampled 2-digit id prefix:
    \$ ./${my_name} --id2
    5A
  Then port them:
    \$ ./${my_name} --id2 5A
    5A:PPPPPPPPPPPPPP...PPP

  Step 4: Port all the sessions:
    \$ ./${my_name} --all

EOF
    exit 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare storer_cid=""
readonly storer_port=4577

declare mapper_cid=""
readonly mapper_port=4547

declare saver_cid=""
readonly saver_port=4537

declare porter_cid=""
readonly porter_port=4517

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

readonly newline=$'\n'

info()
{
  if [ "${SHOW_PORTER_INFO}" = "true" ]; then
    echo "${1}" "${2}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

remove_docker_network()
{
  info "Removing the network ${network_name}"
  docker network rm ${network_name} > /dev/null
}

remove_one_service()
{
  local name=${1}
  local cid=${2}
  if [ -n "${cid}" ]; then
    info "Stopping the ${name} service"
    docker container stop --time 1 "${cid}" > /dev/null
    info "Removing the ${name} service"
    # Very important this does NOT include --volumes
    docker container rm --force "${cid}"    > /dev/null
  fi
}

remove_all_services_and_network()
{
  remove_one_service storer ${storer_cid}
  remove_one_service mapper ${mapper_cid}
  remove_one_service saver  ${saver_cid}
  remove_one_service porter ${porter_cid}
  remove_docker_network
}

create_docker_network()
{
  docker network create --driver bridge ${network_name} > /dev/null
  info "Checking the network ${network_name} has been created. OK"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

error()
{
  local status=${1}
  local msg="${2}"
  >&2 echo "ERROR"
  >&2 echo "${msg}"
  exit "${status}"
}

error_no_prefix()
{
  local status=${1}
  local msg="${2}"
  >&2 echo "${msg}"
  exit "${status}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_installed()
{
  local cmd=${1}
  local status=${2}
  if ! hash "${cmd}" 2> /dev/null ; then
    error "${status}" "${cmd} needs to be installed"
  else
    info "Checking ${cmd} is installed. OK"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exists_container()
{
  local name=${1}
  if docker ps --all --format '{{.Names}}' | grep "${name}" > /dev/null ; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_storer_data_container_exists()
{
  local status=${1}
  if ! docker ps --all | grep "${storer_data_container_name}" > /dev/null ; then
    error "${status}" "Cannot find storer's data-container ${storer_data_container_name}"
  else
    info "Checking storer's data-container exists. OK"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_if_already_running_storer()
{
  local status=${1}
  if exists_container storer ; then
    message+="A storer service is already running${newline}"
    message+="Please run $ [sudo] docker rm -f storer"
    error "${status}" "${message}"
  else
    info 'Checking the storer service is not already running. OK'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_if_already_running_mapper()
{
  local status=${1}
  if exists_container mapper ; then
    message+="A mapper service is already running${newline}"
    message+="Please run $ [sudo] docker rm -f mapper"
    error "${status}" "${message}"
  else
    info 'Checking the mapper service is not already running. OK'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_if_already_running_saver()
{
  local status=${1}
  if exists_container saver ; then
    message+="A saver service is already running${newline}"
    message+="Please run $ [sudo] docker rm -f saver"
    error "${status}" "${message}"
  else
    info 'Checking the saver service is not already running. OK'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_if_already_running_porter()
{
  local status=${1}
  if exists_container porter ; then
    message+="A porter service is already running${newline}"
    message+="Please run $ [sudo] docker rm -f porter"
    error "${status}" "${message}"
  else
    info 'Checking the porter service is not already running. OK'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

wait_until_ready()
{
  local name="${1}"
  local error_code="${2}"
  local method="${3}"
  local max_tries=40
  local vport="${name}_port"
  local port="${!vport}"
  local vcid="${name}_cid"
  local cid="${!vcid}"

  local cmd="curl --silent --fail --data '{}' -X GET http://localhost:${port}/${method}"
  cmd+=" > /dev/null 2>&1"

  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    cmd="docker-machine ssh ${DOCKER_MACHINE_NAME} ${cmd}"
  fi
  info -n "Checking the ${name} service is ready"
  while [ $(( max_tries -= 1 )) -ge 0 ] ; do
    info -n '.'
    if eval "${cmd}" ; then
      info 'OK'
      return 0 # true
    else
      sleep 0.10
    fi
  done
  info 'FAIL'
  local docker_log
  docker_log=$(docker logs "${cid}")
  error_no_prefix "${error_code}" "${docker_log}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_service_storer()
{
  storer_cid=$(docker run \
    --detach \
    --name storer \
    --network ${network_name} \
    --publish ${storer_port}:${storer_port} \
    --user storer \
    --volumes-from "${storer_data_container_name}" \
      cyberdojo/storer)
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_service_mapper()
{
  mapper_cid=$(docker run \
    --detach \
    --name mapper \
    --network ${network_name} \
    --publish ${mapper_port}:${mapper_port} \
    --user nobody \
    --volume "${porter_host_root_dir}/porter:/porter:ro" \
      cyberdojo/mapper)
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_service_saver()
{
  saver_cid=$(docker run \
    --detach \
    --env DOCKER_MACHINE_NAME="${DOCKER_MACHINE_NAME}" \
    --name saver \
    --network ${network_name} \
    --publish ${saver_port}:${saver_port} \
    --user saver \
    --volume "${saver_host_root_dir}/cyber-dojo:/cyber-dojo:rw" \
      cyberdojo/saver)
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_service_porter()
{
  porter_cid=$(docker run \
    --detach \
    --env DOCKER_MACHINE_NAME="${DOCKER_MACHINE_NAME}" \
    --name porter \
    --network ${network_name} \
    --publish ${porter_port}:${porter_port} \
    --user porter \
    --volume "${porter_host_root_dir}/porter:/porter:rw" \
      cyberdojo/porter)
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_port_exec()
{
  # Note: web will use porter's rack-dispatcher API, we don't
  docker exec     \
    --user porter \
    "${porter_cid}" \
      sh -c "ruby /app/src/port.rb ${*}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_help "${*}"

exit_unless_installed docker 1
exit_unless_installed curl 2

exit_unless_storer_data_container_exists 3

exit_if_already_running_storer 4
exit_if_already_running_mapper 5
exit_if_already_running_saver  6
exit_if_already_running_porter 7

create_docker_network
trap remove_all_services_and_network EXIT INT

run_service_storer
run_service_mapper
run_service_saver
run_service_porter

wait_until_ready storer  8 sha
wait_until_ready mapper  9 ready
wait_until_ready saver  10 sha
wait_until_ready porter 11 ready

run_port_exec "${*}"
