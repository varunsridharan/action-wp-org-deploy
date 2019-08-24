FROM debian:stable-slim

RUN apt-get install -y subversion

RUN apt-get install -y rsync

COPY entrypoint.sh /entrypoint.sh

RUN chmod 777 entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]