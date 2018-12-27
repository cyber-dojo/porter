#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_011a_port_id10_malformed_not_base58()
{
  local name=011a
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} new

  export SHOW_PORTER_INFO=false
  local not_base_58=12345£BCDE
  port --id10 ${not_base_58}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id10 <${not_base_58}> (!Base58)"
  assert_status_equals 11
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011b_port_id10_malformed_not_size_10()
{
  local name=011b
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} new

  export SHOW_PORTER_INFO=false
  local not_size_10=12345BCDE
  port --id10 ${not_size_10}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id10 <${not_size_10}> (size==9 !10)"
  assert_status_equals 12
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011c_port_id10_does_not_exist()
{
  local name=011c
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} new

  export SHOW_PORTER_INFO=false
  local not_exist=0F44761F81
  port --id10 ${not_exist}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: id10 <${not_exist}> does not exist"
  assert_status_equals 13
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011d_port_id10_P()
{
  local name=011d
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} new

  export SHOW_PORTER_INFO=false
  local exists=9fH6TumFV2
  port --id10 ${exists}
  cleanup_stubs ${name}

  assert_stdout_equals 'P'
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011d_port_id10_M()
{
  :
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011d_port_id10_E()
{
  :
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
