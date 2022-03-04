#!/bin/bash

function setDoguLogLevel() {
  echo "Mapping dogu specific log level..."
  currentLogLevel=$(doguctl config --default "WARN" "logging/root")

  case "${currentLogLevel}" in
    "INFO")
      export REDIS_LOGLEVEL=notice
    ;;
    "DEBUG")
      export REDIS_LOGLEVEL=debug
    ;;
    "ERROR")
      export REDIS_LOGLEVEL=warning
    ;;
    "FATAL")
      export REDIS_LOGLEVEL=warning
    ;;
    *)
      export REDIS_LOGLEVEL=warning
    ;;
  esac
  doguctl template "${CONF_DIR}/redis.conf.tpl" "${CONF_DIR}/redis.conf"
}