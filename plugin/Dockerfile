ARG CERTBOT_VERSION
ARG PLUGIN_NAME

FROM certbot/certbot:${CERTBOT_VERSION}

COPY certbot/certbot-${PLUGIN_NAME} /opt/certbot/src/certbot-${PLUGIN_NAME}

RUN pip install --constraint /opt/certbot/docker_constraints.txt --no-cache-dir --editable /opt/certbot/src/certbot-${PLUGIN_NAME}
