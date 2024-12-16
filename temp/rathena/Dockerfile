FROM  --platform=$TARGETOS/$TARGETARCH debian:bullseye-slim

ENV   DEBIAN_FRONTEND=noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container

## update base packages
RUN   apt update \
        &&   apt upgrade -y

## install dependencies
RUN   apt install -y iproute2 tar libssl1.1 curl git libncurses5-dev libncursesw5-dev \ 
        libtool zip unzip libncurses5 libncursesw5 python3 openssl locales ffmpeg apt-transport-https libc6  binutils xz-utils liblua5.1-0

RUN  apt -y install git make libmariadbd-dev libmariadb-dev-compat gcc g++ zlib1g-dev libpcre3-dev python3 python3-pip tini procps

## configure locale
RUN   update-locale lang=en_US.UTF-8 \
        &&   dpkg-reconfigure --frontend noninteractive locales



WORKDIR /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
