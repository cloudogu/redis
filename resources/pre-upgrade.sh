#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function run_preupgrade() {
  FROM_VERSION="${1}"
  TO_VERSION="${2}"

  echo "Executing Redis pre-upgrade from ${FROM_VERSION} to ${TO_VERSION}"
  if [ "${FROM_VERSION}" = "${TO_VERSION}" ]; then
    echo "FROM and TO versions are the same; Exiting..."
    exit 0
  fi

  if [[ "$(major_version "${FROM_VERSION}")" -lt 7 ]]; then
    save_acl_with_channel_permissions
  fi

  echo "Redis pre-upgrade done"
}

# Prints the major version of a dogu version, e.g. "6" for "6.2.24-2".
function major_version() {
  echo "${1%%.*}"
}

# Redis 7 changed the default of acl-pubsub-default from allchannels to resetchannels, so
# every ACL user without an explicit channel rule loses all Pub/Sub access after the upgrade.
# The ACL file on the volume is never re-rendered, so it may still hold such users. ACL SAVE
# in the still running redis 6 writes the implicit "&*" of every user into the ACL file,
# which the new redis then loads as it is.
function save_acl_with_channel_permissions() {
  wait_for_redis
  echo "Saving ACL users with explicit Pub/Sub channel permissions..."
  local default_password reply
  default_password="$(doguctl config -e "default_admin_password")"
  # redis-cli exits 0 on error replies but 1 on a failed AUTH, so always check the reply itself
  reply="$(REDISCLI_AUTH="${default_password}" redis-cli --user default acl save 2>&1)" || true
  if [[ "${reply}" != "OK" ]]; then
    echo "ERROR: ACL SAVE failed: ${reply}"
    exit 1
  fi
}

# Waits until redis accepts connections, but not forever.
# redis-cli only exits non-zero if it cannot connect.
function wait_for_redis() {
  local max_tries=20 interval=3 try
  for ((try = 1; try <= max_tries; try++)); do
    if redis-cli ping >/dev/null 2>&1; then
      return 0
    fi
    echo "Waiting for Redis to start... (${try}/${max_tries})"
    sleep "${interval}"
  done
  echo "ERROR: Redis did not accept connections within $((max_tries * interval)) seconds"
  exit 1
}

# make the script only run when executed, not when sourced from bats tests
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_preupgrade "$@"
fi
