FROM alpine:latest

RUN apk add subversion

RUN apk add rsync

COPY entrypoint.sh /entrypoint.sh

RUN chmod 777 entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]