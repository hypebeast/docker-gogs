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

# Expose ports
EXPOSE 3000

# Add VOLUMESs to allow backup and customization of config
VOLUME ["/home/gogs/data"]
VOLUME ["/var/log/gogs"]

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
