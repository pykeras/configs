FROM python:3.14-slim

RUN pip install \
    devpi-server \
    devpi-web

COPY ./entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3141

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
