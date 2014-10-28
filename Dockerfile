FROM ubuntu:trusty
MAINTAINER sebastian.ruml@gmail.com

# Install packages
RUN apt-get update && \
    apt-get -y install wget git rsync

# Install Gogs
ADD assets/setup/ /app/setup/
RUN chmod 755 /app/setup/install.sh
RUN /app/setup/install.sh

# Add Gogs config and run.sh script
ADD assets/config/ /app/setup/config/
ADD assets/run.sh /app/run.sh
RUN chmod 755 /app/run.sh

# TODO: Expose ENV
ENV GOGS_CUSTOM /data/gogs

# Expose ports
EXPOSE 80

# Add VOLUMESs to allow backup and customization of config
VOLUME ["/data"]

CMD ["/app/run.sh"]
