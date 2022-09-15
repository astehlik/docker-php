#!/bin/sh

set -e

PHP_XDEBUG_ENABLE="${PHP_XDEBUG_ENABLE:-0}"
PHP_DOWNGRADE_COMPOSER="${PHP_DOWNGRADE_COMPOSER:-0}"

debug() {
    if [ -n "${DEBUG_ENTRYPOINT}" ] && [ "${DEBUG_ENTRYPOINT}" -eq 1 ]; then
        echo "$1"
    fi
}

if [ "$PHP_XDEBUG_ENABLE" -eq "1" ]; then
        phpenmod xdebug
fi

if [ -n "${PHP_LOCALUSER_UID+x}" ]; then
        debug "Adjusting uid of localuser if user with uid ${PHP_LOCALUSER_UID} does not exist..."
        id "${PHP_LOCALUSER_UID}" > /dev/null 2>&1 || usermod -u "${PHP_LOCALUSER_UID}" localuser
fi

if [ -n "${PHP_LOCALUSER_GID+x}" ]; then
        cliGroupData="$(getent group "${PHP_LOCALUSER_GID}" || echo '')"
        cliGroup="${cliGroupData%%:*}"
        if [ "$cliGroup" = ""  ]; then
                debug "Adjusting gid of localuser group to ${PHP_LOCALUSER_GID}..."
                cliGroup="localuser"
                groupmod -g "${PHP_LOCALUSER_GID}" localuser
        fi
        cliUser="$(id -nu "${PHP_LOCALUSER_UID}")"
        debug "Adding user $cliUser to group $cliGroup"
        usermod -g "$cliGroup" "$cliUser"
fi

if [ "$PHP_DOWNGRADE_COMPOSER" -eq "1" ]; then
        composer self-update --1
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
        set -- php "$@"
fi

if [ -n "${PHP_LOCALUSER_UID+x}" ]; then
        exec sudo --preserve-env -H -u localuser "$@"
else
        exec "$@"
fi
