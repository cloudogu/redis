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
  export STARTUP_DIR=/workspace/resources
  export WORKDIR=/workspace
  export RAILS_ENV=production
  doguctl="$(mock_create)"
  export doguctl
  ln -s "${doguctl}" "${BATS_TMPDIR}/doguctl"
  mysql="$(mock_create)"
  export mysql
  ln -s "${mysql}" "${BATS_TMPDIR}/mysql"
  rake="$(mock_create)"
  export rake
  ln -s "${rake}" "${BATS_TMPDIR}/rake"
  bundle="$(mock_create)"
  export bundle
  ln -s "${bundle}" "${BATS_TMPDIR}/bundle"
  export PATH="${PATH}:${BATS_TMPDIR}"
}

teardown() {
  unset STARTUP_DIR
  unset WORKDIR
  unset RAILS_ENV
  rm "${BATS_TMPDIR}/doguctl"
  rm "${BATS_TMPDIR}/mysql"
  rm "${BATS_TMPDIR}/rake"
  rm "${BATS_TMPDIR}/bundle"
}

@test "versionXLessOrEqualThanY() was properly sourced from pre-upgrade.sh" {
  source /workspace/resources/post-upgrade.sh

  run versionXLessOrEqualThanY "1.0.0-1" "1.0.0-1"
  assert_success
  run versionXLessOrEqualThanY "1.0.0-0" "1.1.1-1"
  assert_success
  run versionXLessOrEqualThanY "1.0.0-1" "0.0.9-1"
  assert_failure
  run versionXLessOrEqualThanY "1.0.0-1" "0.9.0-1"
  assert_failure
}

@test "versionXLessThanY() was properly sourced from pre-upgrade.sh" {
  source /workspace/resources/post-upgrade.sh

  run versionXLessThanY "1.0.0-1" "1.1.0-1"
  assert_success
  run versionXLessThanY "1.0.0-1" "1.1.1-1"
  assert_success
  run versionXLessThanY "1.0.0-1" "1.0.0-1"
  assert_failure
  run versionXLessThanY "1.2.3-4" "0.1.2-3"
  assert_failure
}

@test "run_postupgrade should provide MySQL credentials (while note being exported)" {
  source /workspace/resources/post-upgrade.sh

  mock_set_status "${doguctl}" 0
  mock_set_output "${doguctl}" "theUser" 1
  mock_set_output "${doguctl}" "thePassword" 2
  mock_set_output "${doguctl}" "theDatabase" 3
  mock_set_output "${doguctl}" "somethingElse" 4
  mock_set_status "${mysql}" 0
  mock_set_status "${rake}" 0
  # overwrite plugin env vars for implicit call of install_plugins
  overwritePluginDirsWithTmpDirs

  run run_postupgrade "4.1.0-3" "4.2.0-1"

  assert_success
  assert_line "get data for database connection"
  assert_equal "$(mock_get_call_num "${doguctl}")" "9"
  assert_equal "$(mock_get_call_args "${doguctl}" "1")" "config -e sa-mysql/username"
  assert_equal "$(mock_get_call_args "${doguctl}" "2")" "config -e sa-mysql/password"
  assert_equal "$(mock_get_call_args "${doguctl}" "3")" "config -e sa-mysql/database"

  assert_equal "$(mock_get_call_num "${mysql}")" "2"
  assert_equal "$(mock_get_call_args "${mysql}" "1")" "-pthePassword -hmysql -utheUser -e SELECT COUNT(*) FROM (SELECT 1 FROM easy_currencies WHERE name='Euro' AND iso_code='EUR' LIMIT 1) s; theDatabase"
  assert_equal "$(mock_get_call_args "${mysql}" "2")" "-pthePassword -hmysql -utheUser -e SELECT COUNT(*) FROM (SELECT 1 FROM easy_currencies WHERE name='US Dollar' AND iso_code='USD'  LIMIT 1) s; theDatabase"

  assert_line "Easy Redmine post-upgrade done"

  refute isVarExported "DATABASE_USER"
  refute isVarExported "DATABASE_USER_PASSWORD"
  refute isVarExported "DATABASE_DB"
}

@test "isVarExported() return true or false if a variable is exported or not" {
  local localEnvVar=hidden
  export exportEnvVar=HELLO

  run isVarExported "localEnvVar"
  assert_failure

  run isVarExported "exportEnvVar"
  assert_success
}

function overwritePluginDirsWithTmpDirs() {
  export DEFAULT_PLUGIN_DIRECTORY="$(mktemp -d)"
  aPluginDirectory="$(mktemp -d -p "${DEFAULT_PLUGIN_DIRECTORY}")"
  aPluginFile="$(mktemp -p "${aPluginDirectory}")"
  pluginName="$(basename "${aPluginDirectory}")"
  aPluginFileName="$(basename "${aPluginFile}")"
  export PLUGIN_DIRECTORY="$(mktemp -d)"
  export PLUGIN_STORE="$(mktemp -d)"
}

function isVarExported() {
    local name="${1}"
    if [[ "${!name@a}" == *x* ]]; then
        return 0
    fi

    return 1
}