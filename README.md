
# PHP Docker Images

[![build_and_push](https://github.com/astehlik/docker-php/actions/workflows/build_and_push.yml/badge.svg)](https://github.com/astehlik/docker-php/actions/workflows/build_and_push.yml)

PHP Docker Images are built on the latest Ubuntu LTS and the awesome
[PPA of Ondřej Surý](https://launchpad.net/~ondrej/+archive/ubuntu/php).

All PHP versions that are supported by the PPA are available:

* PHP 5.6
* PHP 7.x
* PHP 8.x

**Warning!** The PHP FPM images are currently only used for testing / development purposes!

The CLI images are used for production deployments and CI pipelines.

## Image types

Three image types are built for each PHP version:

- `base` - PHP base and common extensions  
- `cli` - PHP CLI and additional build tools like Composer and Node.js 
- `fpm` - PHP FPM listening on port 9000 by default

## Image tags

The images can be pulled via:

### GitHub Container Registry

**Tag scheme:** `ghcr.io/astehlik/docker-php/php-<image-type>:<version>`

**Example:** `ghcr.io/astehlik/docker-php/php-cli:8.5`

### Docker Hub

**Tag scheme:** `astehlik/php-<image-type>:<php-version>`

**Example:** `astehlik/php-cli:8.5`

## Permissions concept

All images are currently built to reduce pain with file permissions in mounts. This is the basic idea:

* No custom Docker image built is needed
* Environment variables are used for configuration
* The image is run as root
* The entrypoint scripts adjust the uid and gid in the Container to match the uid / gid of the local user
  * In the CLI images, sudo is used to execute the commands with the adjusted user
  * In the FPM images, the FPM user is adjusted

## Environment variables

### CLI Image

| Variable                      | Purpose                                                                                                                                               | Default           |
|-------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------|
| `PHP_XDEBUG_ENABLE`           | Set to `1` to enable Xdebug                                                                                                                           | `0`               |
| `PHP_DOWNGRADE_COMPOSER`      | Set to `1` to downgrade Composer to version 1                                                                                                         | `0`               |
| `PHP_CLI_USER`                | The user to run the CLI commands as                                                                                                                   | `localuser`       |
| `PHP_CLI_USER_HOME_DIRECTORY` | The home directory of the CLI user                                                                                                                    | `/home/localuser` |
| `DEBUG_ENTRYPOINT`            | Set to `1` to enable debug output of the entrypoint script                                                                                            | `0`               |
| `PHP_LOCALUSER_UID`           | If set, the UID of the `$PHP_CLI_USER` is adjusted to this value                                                                                      |                   |
| `PHP_LOCALUSER_GID`           | If set, group `localuser` is created with this GID and the `$PHP_CLI_USER` is added to this group. If the GID already exists, the user is only added. |                   |
| `PHP_LOCALUSER_PATHS`         | Colon separated list of paths, for which the ownership is changed to the local UID and GID, e.g.: `/my/path:/my/other/path`                           |                   |

### PHP FPM Image

| Variable                            | Purpose                                                 | Default    |
|-------------------------------------|---------------------------------------------------------|------------|
| `PHP_FPM_POOL_LISTEN`               | The port on which PHP FPM should listen                 | `9000`     |
| `PHP_FPM_POOL_USER`                 | The name of the PHP FPM Pool user                       | `www-data` |
| `PHP_FPM_POOL_GROUP`                | The name of the PHP FPM Pool group                      | `www-data` |
| `PHP_FPM_POOL_PM`                   | PHP FPM Pool setting `pm`                               | `dynamic`  |
| `PHP_FPM_POOL_PM_MAX_CHILDREN`      | PHP FPM Pool setting `pm.max_children`                  | `5`        |
| `PHP_FPM_POOL_PM_START_SERVERS`     | PHP FPM Pool setting `pm.start_servers`                 | `2`        |
| `PHP_FPM_POOL_PM_MIN_SPARE_SERVERS` | PHP FPM Pool setting `pm.min_spare_servers`             | `1`        |
| `PHP_FPM_POOL_PM_MAX_SPARE_SERVERS` | PHP FPM Pool setting `pm.max_spare_servers`             | `3`        |
| `PHP_FPM_POOL_PM_STATUS_LISTEN`     | PHP FPM Pool setting `pm.status_listen`                 | `9001`     |
| `PHP_FPM_MAX_REQUESTS`              | PHP FPM Pool setting `pm.max_requests`                  | `500`      |
| `PHP_FPM_XDEBUG_ENABLE`             | Set to `1` to enable PHP Xdebug Extension               | `0`        |
| `PHP_ENABLE_MODS`                   | Enable PHP Extensions before startup (space separated)  |            |
| `PHP_DISABLE_MODS`                  | Disable PHP Extensions before startup (space separated) |            |

## PHP Extensions

These PHP Extensions are installed (depending on their availability for the PHP Version):

- amqp
- apcu
- apcu-bc (PHP >= 7.0 && < 8.0)
- curl
- gd
- igbinary (PHP < 8.2)
- imap
- intl
- json (PHP < 8.0)
- ldap
- mbstring
- mcrypt (PHP < 8.2)
- mysql
- bcmath
- pcov, only in CLI, disabled by default (PHP > 7.0)
- pgsql
- redis
- soap
- sqlite3
- xml
- zip
- xdebug, disabled by default

## Languages

The language packs for these languages are installed:

- English
- German

## Additional Tools in CLI Image

- [Composer](https://getcomposer.org/) (latest version by default, LTS Version 2.2 for older PHP Versions)
- [Node.js](https://nodejs.org/en/download) v22 (LTS) and npm
- Deployment tools (for deploying with [TYPO3 Surf](https://github.com/TYPO3/Surf) or [Deployer](https://deployer.org/)):
  OpenSSH Client, Git, rsync
- Other tools: MariaDB client, wget, jq, make, patch, parallel

## Build the Images

For building the actual `Dockerfile`s, the tool [ORCA](https://github.com/orca-build/orca) is used.

For installing it, you can execute these commands:

```bash

curl -O https://orca-build.io/downloads/orca.zip

unzip -o orca.zip
```

Then you can build the images into the `dist` directory:

```bash
php orca.phar --directory="." generate
```

Finally, you can build the images.

```bash
# Base needs always to be built first
docker build dist/images/base/8.5 --tag ghcr.io/astehlik/docker-php/php-base:8.5

# Then build cli / FPM images
docker build dist/images/cli/8.5 --tag ghcr.io/astehlik/docker-php/php-cli:8.5
docker build dist/images/fpm/8.5 --tag ghcr.io/astehlik/docker-php/php-fpm:8.5
```
