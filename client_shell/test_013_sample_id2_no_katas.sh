#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_013_sample_id2_no_katas()
{
  local name=013
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  export SHOW_PORTER_INFO=true
  port --id2
  cleanup_stubs ${name}

  assert_stdout_includes_all_up_down
  assert_stdout_line_count_equals 17
  assert_stderr_equals 'ERROR: storer is empty!'
  assert_status_equals 12
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
