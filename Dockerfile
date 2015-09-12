FROM ubuntu:trusty
MAINTAINER sebastian.ruml@gmail.com

# Install packages
RUN apt-get update && \
    apt-get -y install wget git rsync unzip supervisor logrotate  \
        postgresql-client openssh-client

ADD assets/setup/ /app/setup/
RUN chmod 755 /app/setup/install
RUN /app/setup/install

ADD assets/config/ /app/setup/config/
ADD assets/init /app/init
RUN chmod 755 /app/init

# env vars
ENV SETUP_DIR /app/setup

ENV GOGS_VERSION v0.6.9
ENV INSTALL_DIR /home/gogs/gogs
ENV DATA_DIR /home/gogs/data
ENV LOG_DIR /home/gogs/data/log
ENV GOGS_DATA_DIR /home/gogs/data/gogs

# TODO: Ist das richtig ?????????
ENV GOGS_CUSTOM /home/gogs/data/gogs/custom
RUN echo "export GOGS_CUSTOM=/home/gogs/data/gogs/custom" >> /etc/profile

# Expose ports
EXPOSE 22 3000

# Add VOLUMESs to allow backup and customization of config
VOLUME ["/home/gogs/data"]
# VOLUME ["/var/log/gogs"]

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
