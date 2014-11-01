#!/bin/sh

GOGS_VERSION=0.5.5
INSTALL_DIR=/home/gogs/gogs
DATA_DIR=/data/gogs
GIT_REPO_DIR=/data/git

# add gogs user
adduser --disabled-login --gecos 'Gogs' gogs
passwd -d gogs

# add git user
adduser --disabled-login --gecos 'gogsgit' git
passwd -d git

# Install Gogs, use local copy if available
mkdir -p ${INSTALL_DIR}
if [ -f ${SETUP_DIR}/gogs-${GOGS_VERSION}.tar.gz ]
then
    tar -zvxf ${SETUP_DIR}/gogs-${GOGS_VERSION}.tar.gz -C ${INSTALL_DIR}
else
    wget -nv "http://gobuild3.qiniudn.com/github.com/gogits/gogs/tag-v-v${GOGS_VERSION}/gogs-linux-amd64.tar.gz" -O - | tar -zvxf - -C ${INSTALL_DIR}
fi

cd ${INSTALL_DIR}
rm -rf ./log ./data

# Symlink folders
ln -sf ${DATA_DIR}/log ./log
ln -sf ${DATA_DIR}/data ./data
ln -sf ${GIT_REPO_DIR} /home/gogs/gogs-repositories

# Create symlink to ${DATA_DIR}/custom/conf
mkdir -p custom
ln -sf ${DATA_DIR}/custom/conf custom/conf

# Fix permissions
chown -R git:git ${INSTALL_DIR}
chmod 755 ${INSTALL_DIR}/gogs
chmod 755 ${INSTALL_DIR}/scripts/start.sh

# cleanup
rm -rf /var/lib/apt/lists/*
