FROM        --platform=$TARGETOS/$TARGETARCH debian:bullseye-slim

ENV     DEBIAN_FRONTEND noninteractive

## install box86
RUN		dpkg --add-architecture armhf

RUN		apt update \
        && apt install -y wget gnupg2 \
		&& wget https://itai-nelken.github.io/weekly-box86-debs/debian/box86.list -O /etc/apt/sources.list.d/box86.list \
		&& wget -qO- https://itai-nelken.github.io/weekly-box86-debs/debian/KEY.gpg | apt-key add - \
		&& apt update && apt install box86:armhf libc6 libc6:armhf -y

## Install box64
RUN         wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list \
            && wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg \
            && apt update && apt install box64-rpi4arm64 -y


RUN     dpkg --add-architecture armhf && \
        apt-get update && \
        apt-get install --yes --no-install-recommends libc6:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf libc6:armhf libncurses5:armhf libsdl2-image-2.0-0:armhf && \
        apt-get -y autoremove && \
        apt-get clean autoclean && \
        rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists
			
ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture armhf \
				&& apt update \
				&& apt upgrade -y \
				&& apt -y --no-install-recommends install ca-certificates curl git wget

RUN         apt install -y libc6:armhf libncurses5:armhf libsdl2-2.0-0:armhf libsdl2-image-2.0-0:armhf libsdl2-mixer-2.0-0:armhf libsdl2-ttf-2.0-0:armhf libopenal1:armhf libpng16-16:armhf libfontconfig1:armhf libxcomposite1:armhf libbz2-1.0:armhf libxtst6:armhf libsm6:armhf libice6:armhf libgl1:armhf libxinerama1:armhf libxdamage1:armhf
			
ENV     STEAMOS=1
ENV     STEAM_RUNTIME=1
ENV     DBUS_FATAL_WARNINGS=0