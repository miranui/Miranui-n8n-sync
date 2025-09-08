FROM n8nio/n8n:latest

USER root

RUN apk add --no-cache curl
RUN npm install -g --no-audit --no-fund jsonwebtoken

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh \
    && chown node:node /docker-entrypoint.sh

COPY ./local-files /files
RUN chown -R node:node /files

ENTRYPOINT ["/docker-entrypoint.sh"]
