ARG CERTBOT_VERSION
ARG PLUGIN_NAME

FROM certbot/certbot:${CERTBOT_VERSION}

COPY certbot/certbot-${PLUGIN_NAME} src/

RUN pip install --constraint docker_constraints.txt --no-cache-dir --editable src/certbot-${PLUGIN_NAME}
