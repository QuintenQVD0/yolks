FROM  --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

ENV   DEBIAN_FRONTEND=noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container

## update base packages
RUN   apt update \
        &&   apt upgrade -y

## install dependencies
RUN   apt install -y iproute2 tar libssl1.1 curl git libncurses5-dev libncursesw5-dev 

RUN apt-get install -y \
    libffmpeg-dev \
    libdl2 \
    libpthread-stubs0-dev \
    libglib2.0-0 \
    libgobject-2.0-0 \
    libgio2.0-cil \
    libnss3 \
    libnssutil3 \
    libsmime3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgtk-3-0 \
    libpango-1.0-0 \
    libcairo2 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libexpat1 \
    libxcb1 \
    libxkbcommon0 \
    libasound2 \
    libatspi2.0-0 \
    libm6 \
    libgcc-s1 \
    libc6 \
    libffi8 \
    libpcre2-8-0 \
    libgmodule-2.0-0 \
    libz1 \
    libmount1 \
    libselinux1 \
    libplc4 \
    libplds4 \
    libgssapi-krb5-2 \
    libavahi-common3 \
    libavahi-client3 \
    libgnutls30 \
    libsystemd0 \
    libgdk-pixbuf-2.0-0 \
    libpangocairo-1.0-0 \
    libharfbuzz0b \
    libpangoft2-1.0-0 \
    libfontconfig1 \
    libfribidi0 \
    libcairo-gobject2 \
    libepoxy0 \
    libxi6 \
    libcloudproviders0 \
    libtracker-sparql-3.0-0 \
    libwayland-client0 \
    libthai0 \
    libpng16-16 \
    libfreetype6 \
    libxrender1 \
    libxcb-render0 \
    libxcb-shm0 \
    libpixman-1-0 \
    libxau6 \
    libblkid1 \
    libkrb5-3 \
    libk5crypto3 \
    libcom-err2 \
    libkrb5support0 \
    libkeyutils1 \
    libssl3 \
    libresolv2 \
    libp11-kit0 \
    libidn2-0 \
    libunistring2 \
    libtasn1-6 \
    libhogweed6 \
    libnettle8 \
    libgmp10 \
    libcap2 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libxcursor1 \
    libxinerama1 \
    libgraphite2-3 \
    libxml2 \
    libjpeg62-turbo \
    libjson-glib-1.0-0 \
    libsqlite3-0 \
    libdatrie1 \
    libbz2-1.0 \
    libbrotli1 \
    liblzma5 \
    libbrotli-dev
 
## configure locale
RUN   update-locale lang=en_US.UTF-8 \
        &&   dpkg-reconfigure --frontend noninteractive locales

WORKDIR /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
