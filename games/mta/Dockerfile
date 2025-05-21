FROM  --platform=$TARGETOS/$TARGETARCH debian:bookworm
ENV   DEBIAN_FRONTEND=noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container

## update base packages
RUN   apt update && \
      apt upgrade -y

## install dependencies
RUN   apt install -y iproute2 \
        curl \
        wget \
        git \
        zip \
        unzip \
        tar \
        xz-utils \
        apt-transport-https \
        openssl \
        libssl3 \
        default-libmysqlclient-dev \
        libmariadb-dev-compat \
        libreadline-dev \
        libncurses-dev \
        libtool \
        python3  \
        locales \
        ffmpeg \
        libc6 \
        binutils \
        liblua5.1-0 

RUN   wget http://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/libmysqlclient21_8.0.42-1debian12_amd64.deb \
        && dpkg -i libmysqlclient21_8.0.42-1debian12_amd64.deb \
        && rm libmysqlclient21_8.0.42-1debian12_amd64.deb

## configure locale
RUN   update-locale lang=en_US.UTF-8 && \
      dpkg-reconfigure --frontend noninteractive locales

WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]