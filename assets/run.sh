#!/bin/sh

INSTALL_DIR=/home/gogs/gogs
DATA_DIR=/data/gogs
GIT_DIR=/data/git

SETUP_DIR=/app/setup
SETUP_CONF_DIR=/app/setup/config

DB_TYPE=${DB_TYPE:-mysql}
DB_HOST=${DB_HOST:-}
DB_PORT=${DB_PORT:-}
DB_NAME=${DB_NAME:-}
DB_USER=${DB_USER:-}
DB_PASS=${DB_PASS:-}

GOGS_PORT=${GOGS_PORT:-3000}
GOGS_DOMAIN=${GOGS_DOMAIN:-localhost}
GOGS_REPO_DIR=/home/gogs/gogs-repositories

# is a mysql database linked?
# requires that the mysql containers have exposed port 3306
if [ -n "${MYSQL_PORT_3306_TCP_ADDR}" ]; then
    DB_TYPE=mysql
    DB_HOST=${DB_HOST:-${MYSQL_PORT_3306_TCP_ADDR}}
    DB_PORT=${DB_PORT:-${MYSQL_PORT_3306_TCP_PORT}}
    DB_USER=${DB_USER:-${MYSQL_ENV_DB_USER}}
    DB_PASS=${DB_PASS:-${MYSQL_ENV_DB_PASS}}
    DB_NAME=${DB_NAME:-${MYSQL_ENV_DB_NAME}}
elif [ -n "${POSTGRESQL_PORT_5432_TCP_ADDR}" ]; then
    DB_TYPE=postgres
    DB_HOST=${DB_HOST:-${POSTGRESQL_PORT_5432_TCP_ADDR}}
    DB_PORT=${DB_PORT:-${POSTGRESQL_PORT_5432_TCP_PORT}}
    DB_USER=${DB_USER:-${POSTGRESQL_ENV_DB_USER}}
    DB_PASS=${DB_PASS:-${POSTGRESQL_ENV_DB_PASS}}
    DB_NAME=${DB_NAME:-${POSTGRESQL_ENV_DB_NAME}}
fi

# Create required folders
if ! test -d ${DATA_DIR}
then
    mkdir -p ${DATA_DIR}/data ${DATA_DIR}/log
fi

if ! test -d ${GIT_DIR}
then
    mkdir -p ${GIT_DIR}
fi

echo ${DB_HOST}

# Handle the custom conf/app.ini
if [ ! -f ${DATA_DIR}/custom/conf/app.ini ]
then
    # Copy custom conf/app.ini
    mkdir -p ${DATA_DIR}/custom/conf
    cp ${SETUP_CONF_DIR}/app.ini ${DATA_DIR}/custom/conf/

    # Configure database
    sed 's/{{DB_TYPE}}/'${DB_TYPE}'/' -i ${DATA_DIR}/custom/conf/app.ini
    sed 's/{{DB_HOST}}/'${DB_HOST}'/' -i ${DATA_DIR}/custom/conf/app.ini
    sed 's/{{DB_PORT}}/'${DB_PORT}'/' -i ${DATA_DIR}/custom/conf/app.ini
    sed 's/{{DB_USER}}/'${DB_USER}'/' -i ${DATA_DIR}/custom/conf/app.ini
    sed 's/{{DB_PASS}}/'${DB_PASS}'/' -i ${DATA_DIR}/custom/conf/app.ini
    sed 's/{{DB_NAME}}/'${DB_NAME}'/' -i ${DATA_DIR}/custom/conf/app.ini

    # Set HTTP_PORT
    sed 's/{{HTTP_PORT}}/'${GOGS_PORT}'/' -i ${DATA_DIR}/custom/conf/app.ini

    # Set Git repo
    sed 's/{{REPO}}/'${GOGS_REPO_DIR}'/' -i ${DATA_DIR}/custom/conf/app.ini

    # Set server config
    sed 's/{{DOMAIN}}/'${GOGS_DOMAIN}'/' -i ${DATA_DIR}/custom/conf/app.ini
fi

cd ${INSTALL_DIR}

# Copy over the conf folder, if no conf folder are found
test -d ${DATA_DIR}/conf || cp -ar ./conf ${DATA_DIR}

# Sync template folders
rsync -rtv ${DATA_DIR}/conf ./conf/

# Copy over the templates, if no templates are found
test -d ${DATA_DIR}/templates || cp -ar ./templates ${DATA_DIR}

# Sync template folders
rsync -rtv ${DATA_DIR}/templates ./templates/

# fix permission and ownership of ${DATA_DIR}
chmod 755 ${DATA_DIR}
chown git:git ${DATA_DIR} -R
chown git:git ${GIT_DIR} -R

# spin up gogs
exec su git -c "./scripts/start.sh"
