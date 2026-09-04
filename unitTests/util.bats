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

  # util.sh runs with 'set -o nounset' and reads CONF_DIR, so it must always be set
  export CONF_DIR="${BATS_TMPDIR}/conf"
  mkdir -p "${CONF_DIR}/data"
}

teardown() {
  rm "${BATS_TMPDIR}/doguctl"
  rm -rf "${CONF_DIR}"
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

@test "rotate_default_user_password() should replace the freshly rendered default user line" {
  source /workspace/resources/util.sh
  local acl_file="${CONF_DIR}/data/service-accounts.acl"
  echo "user default +@all ~* on #aaaa1111aaaa1111aaaa1111aaaa1111aaaa1111aaaa1111aaaa1111aaaa1111" > "${acl_file}"
  mock_set_status "${doguctl}" 0
  mock_set_output "${doguctl}" "false" 1
  mock_set_output "${doguctl}" "newSecret123" 2

  run rotate_default_user_password

  assert_success
  assert_equal "$(cat "${acl_file}")" "user default +@all ~* on #1307237e24b4e7adf8d4156318de83047ea679d676b4f6429813aa8d9e602435"
}

@test "rotate_default_user_password() should keep service accounts, replace the hashed default user and write the marker last" {
  
  # ARRANGE

  source /workspace/resources/util.sh
  local acl_file="${CONF_DIR}/data/service-accounts.acl"
  # add two entries in acl file
  cat > "${acl_file}" <<'EOF'
user default on #ab12 ~* &* +@all
user sa-scm on #99aa ~* &* +@all
EOF
  chmod 640 "${acl_file}"
  mock_set_status "${doguctl}" 0
  mock_set_output "${doguctl}" "false" 1
  mock_set_output "${doguctl}" "newSecret123" 2

  # ACT

  run rotate_default_user_password

  # ASSERT

  assert_success
  # the service account survives, the default user is replaced by the new password
  run cat "${acl_file}"
  assert_line "user sa-scm on #99aa ~* &* +@all"
  assert_line "user default +@all ~* on #1307237e24b4e7adf8d4156318de83047ea679d676b4f6429813aa8d9e602435"
  refute_line "user default on #ab12 ~* &* +@all"
  # exactly 2 entries, default and sa-scm not 2x default
  assert_equal "${#lines[@]}" "2"
  # no leftover temporary file, mode of the volume file is untouched
  assert_file_not_exist "${acl_file}.tmp"
  assert_equal "$(stat -c '%a' "${acl_file}")" "640"
  # the marker is written after the password, so an aborted rotation is retried
  # doguctl call sum
  # #1 config - read rotated flag
  # #2 random - generate password
  # #3 config - write password
  # #4 config - set rotated flag
  assert_equal "$(mock_get_call_num "${doguctl}")" "4"
  assert_equal "$(mock_get_call_args "${doguctl}" 3)" "config -e default_admin_password newSecret123"
  assert_equal "$(mock_get_call_args "${doguctl}" 4)" "config default_admin_password_rotated true"
}

@test "rotate_default_user_password() should do nothing if the rotation marker is already true" {
  source /workspace/resources/util.sh
  local acl_file="${CONF_DIR}/data/service-accounts.acl"
  echo "user default on #ab12 ~* &* +@all" > "${acl_file}"
  mock_set_status "${doguctl}" 0
  mock_set_output "${doguctl}" "true" 1

  run rotate_default_user_password

  assert_success
  assert_equal "$(cat "${acl_file}")" "user default on #ab12 ~* &* +@all"
  # only the marker was read, nothing was generated or written
  assert_equal "$(mock_get_call_num "${doguctl}")" "1"
}

@test "rotate_default_user_password() should do nothing if there is no acl file yet" {
  source /workspace/resources/util.sh
  mock_set_status "${doguctl}" 0
  mock_set_output "${doguctl}" "false" 1

  run rotate_default_user_password

  assert_success
  assert_file_not_exist "${CONF_DIR}/data/service-accounts.acl"
  assert_equal "$(mock_get_call_num "${doguctl}")" "1"
}

@test "password_hash() should hash without a trailing newline so redis accepts the plaintext password" {
  source /workspace/resources/util.sh

  run password_hash "newSecret123"

  assert_success

  assert_output "1307237e24b4e7adf8d4156318de83047ea679d676b4f6429813aa8d9e602435"
}

@test "render_default_user_config() should hand the acl template a hash instead of the plaintext password" {
  source /workspace/resources/util.sh
  mock_set_status "${doguctl}" 0
  mock_set_output "${doguctl}" "newSecret123" 1

  render_default_user_config

  assert_equal "${DEFAULT_ADMIN_PASSWORD_HASH}" "1307237e24b4e7adf8d4156318de83047ea679d676b4f6429813aa8d9e602435"
  # doguctl call sum
  # #1 random   - generate password
  # #2 config   - write password
  # #3 template - render the acl file
  # #4 config   - set rotated flag
  assert_equal "$(mock_get_call_num "${doguctl}")" "4"
  assert_equal "$(mock_get_call_args "${doguctl}" 2)" "config -e default_admin_password newSecret123"
  assert_equal "$(mock_get_call_args "${doguctl}" 3)" "template /service-accounts.acl.tpl ${CONF_DIR}/data/service-accounts.acl"
  assert_equal "$(mock_get_call_args "${doguctl}" 4)" "config default_admin_password_rotated true"
}

@test "render_default_user_config() should do nothing if the acl file already exists" {
  source /workspace/resources/util.sh
  echo "user default +@all ~* on #1234567890123456789012345678901234567890123456789012346578901234" > "${CONF_DIR}/data/service-accounts.acl"
  mock_set_status "${doguctl}" 0

  run render_default_user_config

  assert_success
  assert_equal "$(mock_get_call_num "${doguctl}")" "0"
}
