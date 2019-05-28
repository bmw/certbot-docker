FROM python:2-alpine3.9

ENTRYPOINT [ "certbot" ]
EXPOSE 80 443
VOLUME /etc/letsencrypt /var/lib/letsencrypt
WORKDIR /opt/certbot

COPY certbot/CHANGELOG.md certbot/README.rst certbot/setup.py /opt/certbot/src/

# Generate constraints file to pin dependency versions
COPY certbot/letsencrypt-auto-source/pieces/dependency-requirements.txt /opt/certbot/dependency-requirements.txt
COPY certbot/tools /opt/certbot/tools
RUN sh -c 'cat dependency-requirements.txt | /opt/certbot/tools/strip_hashes.py > /opt/certbot/unhashed_requirements.txt'
RUN sh -c 'cat tools/dev_constraints.txt unhashed_requirements.txt | /opt/certbot/tools/merge_requirements.py > /opt/certbot/docker_constraints.txt'

COPY certbot/acme /opt/certbot/src/
COPY certbot/certbot /opt/certbot/src/

RUN apk add --no-cache --virtual .certbot-deps \
        libffi \
        libssl1.1 \
        openssl \
        ca-certificates \
        binutils
RUN apk add --no-cache --virtual .build-deps \
        gcc \
        linux-headers \
        openssl-dev \
        musl-dev \
        libffi-dev \
    && pip install -r /opt/certbot/dependency-requirements.txt \
    && pip install --no-cache-dir --no-deps \
        --editable /opt/certbot/src/acme \
        --editable /opt/certbot/src \
&& apk del .build-deps
