FROM nginx:stable-alpine AS base
RUN apk add --no-cache openssl apache2-utils

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME [ "/etc/nginx/certs", "/etc/nginx/auth" ]

CMD ["/entrypoint.sh"]
