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
  bundle="$(mock_create)"
  export bundle
  export PATH="${PATH}:${BATS_TMPDIR}"
  ln -s "${bundle}" "${BATS_TMPDIR}/bundle"
}

teardown() {
  unset STARTUP_DIR
  unset WORKDIR
  unset RAILS_ENV
  rm "${BATS_TMPDIR}/doguctl"
  rm "${BATS_TMPDIR}/bundle"
}

@test "install_plugin() should print an error but continue if a plugin directory turns out as regular file" {
  source /workspace/resources/startup.sh
  export PLUGIN_STORE="$(mktemp -d)"
  export PLUGIN_DIRECTORY="a/path/to/a/better/world"
  pluginName="$(mktemp -p ${PLUGIN_STORE})"

  run install_plugin "${pluginName}"

  assert_success
  assert_line --partial "ERROR"
  assert_line --partial "is not a directory"
}

@test "install_plugin() should install a bundled plugin that is absent" {
  source /workspace/resources/startup.sh
  export PLUGIN_STORE="$(mktemp -d)"
  aPluginDirectory="$(mktemp -d -p "${PLUGIN_STORE}")"
  aPluginFile="$(mktemp -p "${aPluginDirectory}")"
  pluginName="$(basename "${aPluginDirectory}")"
  aPluginFileName="$(basename "${aPluginFile}")"
  export PLUGIN_DIRECTORY="$(mktemp -d)"

  run install_plugin "${pluginName}"

  assert_success
  assert_line "remove plugin ${pluginName}"
  assert_line "install plugin ${pluginName}"
  assert_dir_exist "${PLUGIN_DIRECTORY}/${pluginName}"
  assert_file_exist "${PLUGIN_DIRECTORY}/${pluginName}/${aPluginFileName}"
}

@test "install_plugins() should install 1 plugin and call rake afterwards" {
  mock_set_status "${bundle}" 0

  source /workspace/resources/startup.sh

  export PLUGIN_STORE="$(mktemp -d)"
  aPluginDirectory="$(mktemp -d -p "${PLUGIN_STORE}")"
  aPluginFile="$(mktemp -p "${aPluginDirectory}")"
  pluginName="$(basename "${aPluginDirectory}")"
  aPluginFileName="$(basename "${aPluginFile}")"
  export PLUGIN_DIRECTORY="$(mktemp -d)"

  run install_plugins

  assert_success
  assert_line "installing plugins ..."
  assert_line "remove plugin ${pluginName}"
  assert_line "install plugin ${pluginName}"
  assert_line "running plugin migrations ..."
  assert_line "plugin migrations ... done"
  assert_dir_exist "${PLUGIN_DIRECTORY}/${pluginName}"
  assert_file_exist "${PLUGIN_DIRECTORY}/${pluginName}/${aPluginFileName}"
  assert_equal "$(mock_get_call_num "${bundle}")" "2"
  assert_equal "$(mock_get_call_args "${bundle}" "1")" "install"
  assert_equal "$(mock_get_call_args "${bundle}" "2")" "exec rake -f /workspace/Rakefile redmine:plugins:migrate"
}
