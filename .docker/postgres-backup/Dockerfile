FROM postgres:18.6-alpine

ARG SUPERCRONIC_VERSION=v0.2.29
ARG TARGETARCH=amd64

RUN apk add --no-cache aws-cli curl tini bash gnupg \
  && curl -fsSL "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
     -o /usr/local/bin/supercronic \
  && chmod +x /usr/local/bin/supercronic

COPY backup.sh /usr/local/bin/backup.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/backup.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
