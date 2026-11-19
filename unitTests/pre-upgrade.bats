#! /bin/bash
# Bind an unbound BATS variables that fail all tests when combined with 'set -o nounset'
export BATS_TEST_START_TIME="0"
export BATSLIB_FILE_PATH_REM=""
export BATSLIB_FILE_PATH_ADD=""

load '/workspace/target/bats_libs/bats-support/load.bash'
load '/workspace/target/bats_libs/bats-assert/load.bash'
load '/workspace/target/bats_libs/bats-mock/load.bash'
load '/workspace/target/bats_libs/bats-file/load.bash'

setup() {
  doguctl="$(mock_create)"
  export doguctl
  ln -s "${doguctl}" "${BATS_TMPDIR}/doguctl"
  redis_cli="$(mock_create)"
  export redis_cli
  ln -s "${redis_cli}" "${BATS_TMPDIR}/redis-cli"
  export PATH="${PATH}:${BATS_TMPDIR}"
}

teardown() {
  rm "${BATS_TMPDIR}/doguctl"
  rm "${BATS_TMPDIR}/redis-cli"
}

@test "run_preupgrade() should run ACL SAVE as default user when upgrading from redis 6" {
  source /workspace/resources/pre-upgrade.sh
  mock_set_output "${doguctl}" "s3cr3t" 1
  mock_set_output "${redis_cli}" "OK" 1

  run run_preupgrade "6.2.24-2" "8.10.3-1"

  assert_success
  assert_line "Redis pre-upgrade done"
  assert_equal "$(mock_get_call_args "${doguctl}" "1")" "config -e default_admin_password"
  assert_equal "$(mock_get_call_num "${redis_cli}")" "1"
  assert_equal "$(mock_get_call_args "${redis_cli}" "1")" "--no-auth-warning --user default --pass s3cr3t acl save"
}

@test "run_preupgrade() should fail if ACL SAVE does not answer OK" {
  source /workspace/resources/pre-upgrade.sh
  mock_set_output "${doguctl}" "s3cr3t" 1
  mock_set_output "${redis_cli}" "ERR There was an error trying to save the ACLs. Please check the server logs for more information" 1

  run run_preupgrade "6.2.24-2" "8.10.3-1"

  assert_failure
  assert_line "ERROR: ACL SAVE failed: ERR There was an error trying to save the ACLs. Please check the server logs for more information"
  refute_line "Redis pre-upgrade done"
}

@test "run_preupgrade() should fail if redis-cli cannot authenticate" {
  source /workspace/resources/pre-upgrade.sh
  mock_set_output "${doguctl}" "wrong" 1
  mock_set_output "${redis_cli}" "AUTH failed: WRONGPASS invalid username-password pair or user is disabled." 1
  mock_set_status "${redis_cli}" 1 1

  run run_preupgrade "6.2.24-2" "8.10.3-1"

  assert_failure
  assert_line "ERROR: ACL SAVE failed: AUTH failed: WRONGPASS invalid username-password pair or user is disabled."
}

@test "run_preupgrade() should not touch the ACL file when upgrading from redis 7 or newer" {
  source /workspace/resources/pre-upgrade.sh

  run run_preupgrade "8.10.3-1" "8.10.4-1"

  assert_success
  assert_line "Redis pre-upgrade done"
  assert_equal "$(mock_get_call_num "${doguctl}")" "0"
  assert_equal "$(mock_get_call_num "${redis_cli}")" "0"
}

@test "run_preupgrade() should do nothing if both versions are the same" {
  source /workspace/resources/pre-upgrade.sh

  run run_preupgrade "6.2.24-2" "6.2.24-2"

  assert_success
  assert_line "FROM and TO versions are the same; Exiting..."
  assert_equal "$(mock_get_call_num "${redis_cli}")" "0"
}

@test "major_version() should print the major version of a dogu version" {
  source /workspace/resources/pre-upgrade.sh

  run major_version "6.2.24-2"

  assert_success
  assert_output "6"
}
