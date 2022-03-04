#!/bin/bash -e

SERVICE="$1"
if [[ X"${SERVICE}" == X"" ]]; then
    echo "usage create-sa.sh servicename"
    exit 1
fi

{
    PASSWORD=$(doguctl random)

    redis-cli --no-auth-warning --user default --pass defaultpasswd acl setuser "${SERVICE}" on +@all ~* \&* \>"${PASSWORD}"
    redis-cli --no-auth-warning --user default --pass defaultpasswd acl save
} >/dev/null 2>&1

# print details
echo "username: ${SERVICE}"
echo "password: ${PASSWORD}"
