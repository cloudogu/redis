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
  export PATH="${PATH}:${BATS_TMPDIR}"
}

teardown() {
  rm "${BATS_TMPDIR}/doguctl"
}

@test "setDoguLogLevel() should set log level to notice  if INFO was configured" {
  source /workspace/resources/util.sh
   mock_set_status "${doguctl}" 0
   mock_set_output "${doguctl}" "INFO" 1

  run getDoguLogLevel

  assert_success
  assert_line "notice"
  assert_equal "$(mock_get_call_num "${doguctl}")" "1"
}

@test "setDoguLogLevel() should set log level to debug   if DEBUG was configured" {
  source /workspace/resources/util.sh
   mock_set_status "${doguctl}" 0
   mock_set_output "${doguctl}" "DEBUG" 1

  run getDoguLogLevel

  assert_success
  assert_line "debug"
  assert_equal "$(mock_get_call_num "${doguctl}")" "1"
}

@test "setDoguLogLevel() should set log level to warning if ERROR was configured" {
  source /workspace/resources/util.sh
   mock_set_status "${doguctl}" 0
   mock_set_output "${doguctl}" "ERROR" 1

  run getDoguLogLevel

  assert_success
  assert_line "warning"
  assert_equal "$(mock_get_call_num "${doguctl}")" "1"
}

@test "setDoguLogLevel() should set log level to warning if FATAL was configured" {
  source /workspace/resources/util.sh
   mock_set_status "${doguctl}" 0
   mock_set_output "${doguctl}" "FATAL" 1

  run getDoguLogLevel

  assert_success
  assert_line "warning"
  assert_equal "$(mock_get_call_num "${doguctl}")" "1"
}

@test "setDoguLogLevel() should set log level to warning if WARN was configured" {
  source /workspace/resources/util.sh
   mock_set_status "${doguctl}" 0
   mock_set_output "${doguctl}" "WARN" 1

  run getDoguLogLevel

  assert_success
  assert_line "warning"
  assert_equal "$(mock_get_call_num "${doguctl}")" "1"
}

@test "setDoguLogLevel() should set log level to warning if nothing was configured" {
  source /workspace/resources/util.sh
   mock_set_status "${doguctl}" 0
   mock_set_output "${doguctl}" "" 1

  run getDoguLogLevel

  assert_success
  assert_line "warning"
  assert_equal "$(mock_get_call_num "${doguctl}")" "1"
}
