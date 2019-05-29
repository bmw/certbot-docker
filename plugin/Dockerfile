ARG CERTBOT_VERSION

FROM certbot/certbot:${CERTBOT_VERSION}

ARG PLUGIN_NAME

COPY certbot/certbot-${PLUGIN_NAME} /opt/certbot/src/certbot-${PLUGIN_NAME}

RUN pip install --constraint /opt/certbot/docker_constraints.txt --no-cache-dir --editable /opt/certbot/src/certbot-${PLUGIN_NAME}
