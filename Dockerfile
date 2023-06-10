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
    ca-certificates-mono \
    libmono-system-net-http4.0-cil \
    libmono-corlib4.5-cil \
    libmono-microsoft-csharp4.0-cil \
    libmono-posix4.0-cil \
    libmono-system-componentmodel-dataannotations4.0-cil \
    libmono-system-configuration-install4.0-cil \
    libmono-system-configuration4.0-cil \
    libmono-system-core4.0-cil \
    libmono-system-data-datasetextensions4.0-cil \
    libmono-system-data4.0-cil \
    libmono-system-identitymodel4.0-cil \
    libmono-system-io-compression4.0-cil \
    libmono-system-numerics4.0-cil \
    libmono-system-runtime-serialization4.0-cil \
    libmono-system-security4.0-cil \
    libmono-system-servicemodel4.0a-cil \
    libmono-system-serviceprocess4.0-cil \
    libmono-system-transactions4.0-cil \
    libmono-system-web4.0-cil \
    libmono-system-xml-linq4.0-cil \
    libmono-system-xml4.0-cil \
    libmono-system4.0-cil \
    mono-runtime \
    mono-vbnc && \   
  echo "**** install radarr ****" && \
  mkdir -p /app/radarr/bin && \
  if [ -z ${RADARR_RELEASE+x} ]; then \
    RADARR_RELEASE=$(curl -sL "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/changes" \
    | jq -r '.[0].version'); \
  fi && \
  curl -o \
    /tmp/radarr.tar.gz -L \
    "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/updatefile?version=${RADARR_RELEASE}&arch=arm64" && \
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
