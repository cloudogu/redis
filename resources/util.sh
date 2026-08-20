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

# Length of the redis default user's password, as generated since the very first release.
DEFAULT_ADMIN_PASSWORD_LENGTH=12

# Prints a new password for the redis default user.
function generate_default_admin_password() {
  doguctl random -l "${DEFAULT_ADMIN_PASSWORD_LENGTH}"
}

# Prints the ACL file without the default user's line, all other lines unchanged:
#   user default on #ab12 ~* &* +@all   -> dropped
#   user sa-scm  on #99aa ~* &* +@all   -> kept
function acl_without_default_user() {
  awk '$1 == "user" && $2 == "default" { next } { print }' "${1}"
}

function render_default_user_config() {
  # only render service accounts file if it does not already exists
  if [[ -f "${CONF_DIR}/data/service-accounts.acl" ]]; then
    return
  fi
  local default_password
  default_password=$(generate_default_admin_password)
  doguctl config -e 'default_admin_password' "${default_password}"
  doguctl template "/service-accounts.acl.tpl" "${CONF_DIR}/data/service-accounts.acl"
  # A freshly rendered password already comes from the fixed doguctl, so there is
  # nothing left to migrate for this instance.
  doguctl config 'default_admin_password_rotated' "true"
}

# Replaces a default_admin_password that was generated with an insecure doguctl random.
# Here the redis server is guaranteed to be down and starts right after this function
function rotate_default_user_password() {
  local acl_file="${CONF_DIR}/data/service-accounts.acl"
  local rotated new_password
  rotated="$(doguctl config -d "false" 'default_admin_password_rotated')"
  # if rotated or first time, no rotation
  if [[ "${rotated}" == "true" ]] || [[ ! -f "${acl_file}" ]]; then
    return
  fi

  echo "Rotating default_admin_password to replace a potentially insecure value..."
  new_password="$(generate_default_admin_password)"

  # Drop the default user, then append it with the new password. Every other line is a
  # service account written by ACL SAVE and must survive
  acl_without_default_user "${acl_file}" > "${acl_file}.tmp"
  echo "user default +@all ~* on >${new_password}" >> "${acl_file}.tmp"
  # Copy to ensure owner and mode of the original file are kept.
  cat "${acl_file}.tmp" > "${acl_file}"
  rm -f "${acl_file}.tmp"

  # Save to dogu config and store rotated status
  doguctl config -e 'default_admin_password' "${new_password}"
  doguctl config 'default_admin_password_rotated' "true"
}

function render_configuration() {
  doguctl template "/redis.conf.tpl" "${CONF_DIR}/redis.conf"
}