#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_008_unknown_args()
{
  local name=008
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  port alpha beta
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_includes 'ERROR: unknown arg <alpha>'
  assert_stderr_includes 'ERROR: unknown arg <beta>'
  assert_status_equals 10
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
