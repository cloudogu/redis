#!/bin/bash

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

function render_configuration() {
  doguctl template "${CONF_DIR}/redis.conf.tpl" "${CONF_DIR}/redis.conf"
}