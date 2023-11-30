#FROM debian:bullseye-slim as build

#RUN dpkg --add-architecture armhf && \
#    apt-get update && \
#    apt-get install --yes --no-install-recommends git  python3 build-essential cmake ca-certificates && \
#    apt-get install --yes --no-install-recommends gcc-arm-linux-gnueabihf libc6-dev-armhf-cross libc6:armhf libstdc++6:armhf && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

#RUN git clone https://github.com/ptitSeb/box86.git; mkdir /box86/build

#WORKDIR /box86/build
#RUN cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
#    make -j$(nproc) && \
#    make install DESTDIR=/tmp/install


FROM --platform=linux/arm64 golang:1.19.3-bullseye as builder

RUN 	apt update \
		&& apt install -y git curl gcc musl-dev

RUN 	git clone https://github.com/gorcon/rcon-cli.git \
		&& cd rcon-cli/ \
		&& go get -v -t -d ./... \
		&& go build -v ./cmd/gorcon \
		&& mv gorcon /tmp/rcon

FROM  debian:bullseye-slim

RUN		dpkg --add-architecture armhf

RUN		apt update \
        && apt install -y wget gnupg2 \
		&& wget https://ryanfortner.github.io/box86-debs/box86.list -O /etc/apt/sources.list.d/box86.list \
		&& wget -qO- https://ryanfortner.github.io/box86-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg  \
        && apt update && apt install box86-rpi4arm64:armhf libc6 libc6:armhf -y 


#COPY --from=build /tmp/install /
COPY --from=builder /tmp/rcon /usr/local/bin/rcon

RUN dpkg --add-architecture armhf && \
    apt-get update && \
    apt-get install --yes --no-install-recommends libc6:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf libc6:armhf libncurses5:armhf libpulse0:armhf libpulse-dev:armhf libatomic1:armhf && \
    apt-get -y autoremove && \
    apt update && \
    apt-get clean autoclean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists
	
			
RUN 		 apt-get update && apt-get install -y apt-transport-https

RUN          apt install -y libc++-dev libc6 git wget curl tar zip unzip binutils xz-utils liblzo2-2 cabextract iproute2 net-tools libatomic1 libsdl1.2debian libsdl2-2.0-0 \
             libfontconfig libicu67 icu-devtools libunwind8 libssl-dev sqlite3 libsqlite3-dev libmariadbclient-dev-compat libduktape205 locales ffmpeg gnupg2 apt-transport-https software-properties-common ca-certificates \
             libz-dev rapidjson-dev tzdata libevent-dev libzip4 libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 build-essential cmake libgdiplus libpulse0 libpulse-dev libatomic1 netcat \
             libflashrom1 libftdi1-2 telnet tini screen libxi6 xvfb

RUN     update-locale lang=en_US.UTF-8 \
        && dpkg-reconfigure --frontend noninteractive locales

##Install box64
RUN         wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list \
            && wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg \
            && apt update && apt install box64-rpi4arm64 -y

## steamcmd specific packages            
RUN        apt install -y libc6:armhf libncurses5:armhf libsdl2-2.0-0:armhf libsdl2-image-2.0-0:armhf libsdl2-mixer-2.0-0:armhf libsdl2-ttf-2.0-0:armhf libopenal1:armhf libpng16-16:armhf libfontconfig1:armhf libxcomposite1:armhf libbz2-1.0:armhf libxtst6:armhf libsm6:armhf libice6:armhf libgl1:armhf libxinerama1:armhf libxdamage1:armhf

ENV     STEAMOS=1
ENV     STEAM_RUNTIME=1
ENV     DBUS_FATAL_WARNINGS=0

RUN		useradd -d /home/container -m container
USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
