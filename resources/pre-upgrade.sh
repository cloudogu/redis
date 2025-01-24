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

  echo "Redis pre-upgrade done"
}

# make the script only run when executed, not when sourced from bats tests
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
until redis-cli ping; do
  echo "Waiting for Redis to start..."
  sleep 3
done
  run_preupgrade "$@"
fi