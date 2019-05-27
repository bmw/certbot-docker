FROM python:2-alpine3.9

ARG CERTBOT_VERSION

ENTRYPOINT [ "certbot" ]
EXPOSE 80 443
VOLUME /etc/letsencrypt /var/lib/letsencrypt
WORKDIR /opt/certbot

RUN apk add --no-cache --virtual .fetch-deps git \
 && git clone https://github.com/certbot/certbot.git --branch "${CERTBOT_VERSION}" --single-branch --depth=1 /root/build \
 && mkdir src

RUN cp /root/build/CHANGELOG.md /root/build/README.rst /root/build/setup.py src \
 && cp /root/build/letsencrypt-auto-source/pieces/dependency-requirements.txt .

RUN cp -r /root/build/tools tools \
 && cat dependency-requirements.txt | tools/strip_hashes.py > unhashed_requirements.txt \
 && cat tools/dev_constraints.txt unhashed_requirements.txt | tools/merge_requirements.py > docker_constraints.txt \
 && cp -r /root/build/acme /root/build/certbot src \
 && apk del .fetch-deps git \
 && rm -rf /root/build/

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
    && pip install -r dependency-requirements.txt \
    && pip install --no-cache-dir --no-deps \
        --editable src/acme \
        --editable src \
&& apk del .build-deps
