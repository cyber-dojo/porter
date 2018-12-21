#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_already_running_porter()
{
  local name=${FUNCNAME[0]}
  create_stub_storer_data_container ${name}
  create_root_dir_for_saver_volume_mount ${name}
  create_root_dir_for_porter_volume_mount ${name}
  docker run --detach --name "${name}" alpine > /dev/null

  port --sample10
  docker rm --force "${name}"
  #dump_sss

  assert_stdout_equals ''

  assert_stderr_includes "ERROR: The porter service is already running"
  assert_stderr_includes "Please run $ [sudo] docker rm -f porter"

  assert_status_equals 5
  #TODO: needs cleanup
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
