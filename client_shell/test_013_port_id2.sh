#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

export SHOW_PORTER_INFO=false

test_013a_port_id2_malformed_not_base58()
{
  local name=015a
  local not_base_58=£B
  create_stubs_and_insert_test_data ${name} new
  port --id2 ${not_base_58}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id2 <${not_base_58}> (!Base58)"
  assert_status_equals 14
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_013b_port_id2_malformed_not_size_2()
{
  local name=013b
  local not_size_2=12345BCDE
  create_stubs_and_insert_test_data ${name} new
  port --id2 ${not_size_2}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id2 <${not_size_2}> (size==9 !2)"
  assert_status_equals 15
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_013c_port_id2_does_not_exist()
{
  local name=013c
  local not_exist=0F
  create_stubs_and_insert_test_data ${name} new
  port --id2 ${not_exist}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: id2 <${not_exist}> does not exist"
  assert_status_equals 16
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_013d_port_id2_all_Ps()
{
  local name=013d
  local id2=9f
  create_stubs_and_insert_test_data ${name} new
  port --id2 ${id2}
  cleanup_stubs ${name}

  assert_stdout_includes "${id2}:PPPPPPPPP"
  assert_stdout_includes "P(9),M(0),E(0)"
  assert_stdout_line_count_equals 2
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_013e_port_id2_all_Ms()
{
  local name=013e
  local id2=0B
  create_stubs_and_insert_test_data ${name} dup_client
  port --id2 ${id2}
  cleanup_stubs ${name}

  assert_stdout_includes "${id2}:MM"
  assert_stdout_includes "P(0),M(2),E(0)"
  assert_stdout_line_count_equals 2
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_013f_port_id2_all_Es()
{
  local name=013d
  local id2=4D
  create_stubs_and_insert_test_data ${name} throws
  port --id2 ${id2}
  cleanup_stubs ${name}

  assert_stdout_includes "${id2}:EE"
  assert_stdout_includes "P(0),M(0),E(2)"
  assert_stdout_line_count_equals 2
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
