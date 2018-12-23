#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_002_storer_already_exists()
{
  local name=002a
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  docker run --detach --name "${name}-storer" alpine > /dev/null
  port --nolog --id10
  docker rm --force "${name}-storer" > /dev/null
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_includes "ERROR: A storer service already exists"
  assert_stderr_includes "Please run $ [sudo] cyber-dojo down"
  assert_status_equals 2
}

test_002_storer_already_exists_with_log()
{
  local name=002a
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  docker run --detach --name "${name}-storer" alpine > /dev/null
  port --id10
  docker rm --force "${name}-storer" > /dev/null
  cleanup_stubs ${name}

  assert_stdout_includes_docker_installed
  assert_stdout_includes_curl_installed
  assert_stdout_includes_storer_not_running
  assert_stdout_line_count_equals 3

  assert_stderr_includes "ERROR: A storer service already exists"
  assert_stderr_includes "Please run $ [sudo] cyber-dojo down"
  
  assert_status_equals 3
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
