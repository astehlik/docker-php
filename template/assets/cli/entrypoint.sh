#!/bin/bash

set -e

PHP_XDEBUG_ENABLE="${PHP_XDEBUG_ENABLE:-0}"
PHP_DOWNGRADE_COMPOSER="${PHP_DOWNGRADE_COMPOSER:-0}"
PHP_CLI_USER="localuser"
PHP_CLI_USER_HOME_DIRECTORY="${PHP_CLI_USER_HOME_DIRECTORY:-/home/localuser}"

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
  id "${PHP_LOCALUSER_UID}" >/dev/null 2>&1 || usermod -u "${PHP_LOCALUSER_UID}" localuser
  PHP_CLI_USER="$(id -nu "${PHP_LOCALUSER_UID}")"
fi

if [ -n "${PHP_LOCALUSER_GID+x}" ]; then
  cliGroupData="$(getent group "${PHP_LOCALUSER_GID}" || echo '')"
  cliGroup="${cliGroupData%%:*}"
  if [ "$cliGroup" = "" ]; then
    debug "Adjusting gid of localuser group to ${PHP_LOCALUSER_GID}..."
    cliGroup="localuser"
    groupmod -g "${PHP_LOCALUSER_GID}" localuser
  fi
  cliUser="$(id -nu "${PHP_LOCALUSER_UID}")"
  debug "Adding user $cliUser to group $cliGroup"
  usermod -g "$cliGroup" "$cliUser" >/dev/null
fi

if [ -n "${PHP_LOCALUSER_PATHS+x}" ]; then
  debug "Adjusting ownership of ${PHP_LOCALUSER_PATHS}..."

  IFS=: read -r -a patharr <<<"$PHP_LOCALUSER_PATHS"

  for dir in "${patharr[@]}"; do
    chown "${PHP_LOCALUSER_UID-1000}":"${PHP_LOCALUSER_GID-1000}" "$dir"
  done
fi

if [ "$PHP_DOWNGRADE_COMPOSER" -eq "1" ]; then
  composer self-update --1
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
  set -- php "$@"
fi

if [ -z "${PHP_LOCALUSER_UID+x}" ]; then
  exec "$@"
fi

if [ "$PHP_CLI_USER" != "localuser" ]; then
  debug "Adjust home directory of user $PHP_CLI_USER to ${PHP_CLI_USER_HOME_DIRECTORY}..."
  mkdir -p "${PHP_CLI_USER_HOME_DIRECTORY}"
  chown "${PHP_LOCALUSER_UID}":"${PHP_LOCALUSER_GID}" "${PHP_CLI_USER_HOME_DIRECTORY}"
  usermod -d /home/localuser "$PHP_CLI_USER"
fi

exec sudo --preserve-env -H -u "${PHP_CLI_USER}" "$@"
