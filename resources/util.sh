#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function getDoguLogLevel() {
  currentLogLevel=$(doguctl config --default "WARN" "logging/root")
  local log_level
  log_level=warning

  case "${currentLogLevel}" in
    "INFO")
      log_level=notice
    ;;
    "DEBUG")
      log_level=debug
    ;;
    "ERROR")
      log_level=warning
    ;;
    "FATAL")
      log_level=warning
    ;;
  esac

  echo "${log_level}"
}

function render_default_user_config() {
  # only render service accounts file if it does not already exists
  if [[ -f "${CONF_DIR}/data/service-accounts.acl" ]]; then
    return
  fi
  local default_password
  default_password=$(doguctl random -l 12)
  doguctl config -e 'default-admin-password' "${default_password}"
  doguctl template "/service-accounts.acl.tpl" "${CONF_DIR}/data/service-accounts.acl"
}

function render_configuration() {
  doguctl template "/redis.conf.tpl" "${CONF_DIR}/redis.conf"
}