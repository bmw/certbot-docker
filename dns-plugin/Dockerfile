ARG CERTBOT_VERSION
ARG DNS_PLUGIN_NAME

FROM certbot/certbot:${CERTBOT_VERSION}

COPY . src/certbot-dns-${DNS_PLUGIN_NAME}

RUN pip install --constraint docker_constraints.txt --no-cache-dir --editable src/certbot-dns-${DNS_PLUGIN_NAME}
