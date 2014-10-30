#!/bin/sh

INSTALL_DIR=/home/gogs/gogs
DATA_DIR=/data/gogs

SETUP_DIR=/app/setup
SETUP_CONF_DIR=/app/setup/config

DB_HOST=${DB_HOST:-}
DB_PORT=${DB_PORT:-}
DB_NAME=${DB_NAME:-}
DB_USER=${DB_USER:-}
DB_PASS=${DB_PASS:-}

GOGS_PORT=${GOGS_PORT:-3000}

# is a mysql database linked?
# requires that the mysql containers have exposed port 3306
if [ -n "${MYSQL_PORT_3306_TCP_ADDR}" ]; then
    DB_HOST=${DB_HOST:-${MYSQL_PORT_3306_TCP_ADDR}}
    DB_PORT=${DB_PORT:-${MYSQL_PORT_3306_TCP_PORT}}
    DB_USER=${DB_USER:-${MYSQL_ENV_DB_USER}}
    DB_PASS=${DB_PASS:-${MYSQL_ENV_DB_PASS}}
    DB_NAME=${DB_NAME:-${MYSQL_ENV_DB_NAME}}
fi

# Create required folders
if ! test -d ${DATA_DIR}
then
    mkdir -p ${DATA_DIR}/data ${DATA_DIR}/log ${DATA_DIR}/conf ${DATA_DIR}/../git
fi

# fix permission and ownership of ${DATA_DIR}
chmod 755 ${DATA_DIR}
chown git:git ${DATA_DIR} -R

cd ${INSTALL_DIR}

# Add the custom configuration if its not found
if [ ! -f ${DATA_DIR}/custom/conf/app.ini ]
then
    mkdir -p ${DATA_DIR}/custom/conf
    cp ${SETUP_DIR}/config/app.ini ${DATA_DIR}/custom/conf/

    # Configure database
    sudo -u git -H sed -i .bak 's/{{DB_HOST}}/'"${DB_HOST}"'/' ${DATA_DIR}/custom/conf/app.ini
    sudo -u git -H sed -i .bak 's/{{DB_PORT}}/'"${DB_PORT}"'/' ${DATA_DIR}/custom/conf/app.ini
    sudo -u git -H sed -i .bak 's/{{DB_USER}}/'"${DB_USER}"'/' ${DATA_DIR}/custom/conf/app.ini
    sudo -u git -H sed -i .bak 's/{{DB_PASS}}/'"${DB_PASS}"'/' ${DATA_DIR}/custom/conf/app.ini
    sudo -u git -H sed -i .bak 's/{{DB_NAME}}/'"${DB_NAME}"'/' ${DATA_DIR}/custom/conf/app.ini

    # Set HTTP_PORT
    sudo -u git -H sed -i .bak  's/{{HTTP_PORT}}/'"${GOGS_PORT}"'/' ${DATA_DIR}/custom/conf/app.ini
fi

# Create symlink to ${DATA_DIR}/custom/conf
mkdir -p custom
ln -sf ${DATA_DIR}/custom/conf custom/conf

cp -ar ./conf ${DATA_DIR}
rm -rf conf
ln -sf ${DATA_DIR}/conf conf

# Copy over the templates, if no templates are found
test -d ${DATA_DIR}/templates || cp -ar ./templates ${DATA_DIR}

# Sync template folders
rsync -rtv ${DATA_DIR}/templates ./templates/

# spin up gogs
exec su git -c "./scripts/start.sh"
