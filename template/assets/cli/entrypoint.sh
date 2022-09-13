#!/bin/sh

set -e

PHP_XDEBUG_ENABLE="${PHP_XDEBUG_ENABLE:-0}"
PHP_DOWNGRADE_COMPOSER="${PHP_DOWNGRADE_COMPOSER:-0}"

if [ "$PHP_XDEBUG_ENABLE" -eq "1" ]; then
        phpenmod xdebug
fi

if [ "$PHP_DOWNGRADE_COMPOSER" -eq "1" ]; then
        composer self-update --1
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
        set -- php "$@"
fi

exec "$@"
