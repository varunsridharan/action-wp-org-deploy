FROM alpine:latest

RUN apt-get update && apt-get install -y subversion rsync && apt-get clean -y  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]