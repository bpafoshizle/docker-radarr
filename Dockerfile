# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:arm64v8-jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG RADARR_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="bpafoshizle"

# set environment variabls
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"
ARG RADARR_BRANCH="master"

RUN \
 echo "**** add mediaarea repository ****" && \
  curl -L \
    "https://mediaarea.net/repo/deb/repo-mediaarea_1.0-21_all.deb" \
    -o /tmp/key.deb && \
  dpkg -i /tmp/key.deb && \
  echo "deb https://mediaarea.net/repo/deb/ubuntu jammy main" | tee /etc/apt/sources.list.d/mediaarea.list && \
  echo "**** install packages ****" && \
  dpkg --add-architecture arm64 && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libsqlite3-0 \
    libicu70 \
    mediainfo \
    musl:arm64 \
    libstdc++6-arm64-cross && \    
  echo "**** install radarr ****" && \
  mkdir -p /app/radarr/bin && \
  if [ -z ${RADARR_RELEASE+x} ]; then \
    RADARR_RELEASE=$(curl -sL "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/changes?runtime=netcore&os=linuxmusl" \
    | jq -r '.[0].version'); \
  fi && \
  curl -o \
    /tmp/radarr.tar.gz -L \
    "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/updatefile?version=${RADARR_RELEASE}&os=linuxmusl&runtime=netcore&arch=arm64" && \
  tar xzf \
    /tmp/radarr.tar.gz -C \
    /app/radarr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${RADARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/radarr/package_info && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /app/radarr/bin/Radarr.Update \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 7878

VOLUME /config
