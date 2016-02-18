# ubunut 15 saves about 50MB over ubuntu stable
FROM alpine:latest
MAINTAINER Joey Baker <joey@byjoeybaker.com>

ENV SYNCTHING_VERSION 0.12.19

RUN apk add --update curl ca-certificates gnupg dpkg \
  && rm -rf /var/cache/apk/*

RUN which dpkg

# grab gosu for easy step-down from root
RUN gpg --keyserver pgp.mit.edu --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -L "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

# get syncthing
WORKDIR /srv
RUN addgroup user \
	&& adduser -s /bin/bash -G user -S syncthing
RUN curl -L -o syncthing.tar.gz https://github.com/syncthing/syncthing/releases/download/v$SYNCTHING_VERSION/syncthing-linux-amd64-v$SYNCTHING_VERSION.tar.gz \
  && tar -xzvf syncthing.tar.gz \
  && rm -f syncthing.tar.gz \
  && mv syncthing-linux-amd64-v* syncthing \
  && rm -rf syncthing/etc \
  && rm -rf syncthing/*.pdf \
  && mkdir -p /srv/config \
  && mkdir -p /srv/data

VOLUME ["/srv/data", "/srv/config"]

ADD ./start.sh /srv/start.sh
RUN chmod 770 /srv/start.sh

RUN apk del curl ca-certificates gnupg dpkg \
  && rm -rf /var/cache/apk/*

ENV UID=1027

ENTRYPOINT ["/srv/start.sh"]

