FROM alpine:latest

RUN apk add subversion

RUN apk add rsync

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]