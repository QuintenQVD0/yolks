FROM --platform=linux/arm64 golang:1.19.3-bullseye as builder

RUN 	apt update \
		&& apt install -y git curl gcc musl-dev

RUN 	git clone https://github.com/gorcon/rcon-cli.git \
		&& cd rcon-cli/ \
		&& go get -v -t -d ./... \
		&& CGO_ENABLED=1 go build -ldflags "-s -w -X main.ServiceVersion=docker" -v ./cmd/gorcon \
		&& mv gorcon /tmp/rcon

FROM --platform=$TARGETOS/$TARGETARCH  ubuntu:22.04

ENV   DEBIAN_FRONTEND noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container

RUN     apt update && apt -y install software-properties-common 
RUN  	add-apt-repository ppa:fex-emu/fex 
RUN 	apt update 
RUN 	apt -y install fex-emu-armv8.0 fex-emu-binfmt32 fex-emu-binfmt64

RUN		apt update 
RUN  	apt -y install curl git iproute2 libssl-dev squashfuse fuse squashfs-tools tzdata tar wget zip build-essential unzip gdb gettext screen numactl libc6 libstdc++6 
RUN     wget http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb 
RUN 	dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb 
RUN 	ls -la /usr/local/bin

## PROTON
RUN         apt update
RUN         apt install -y --no-install-recommends software-properties-common libntlm0 winbind xauth libncurses6 dbus libgdiplus
RUN         apt install -y alsa-tools pulseaudio libasound2 libao-common gnutls-bin gnupg numactl curl python3 python3-pip python3-setuptools

## Download Proton GE
RUN         curl -sLOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)"
RUN         tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1
RUN         rm GE-Proton*.*

COPY --from=builder /tmp/rcon /usr/local/bin/rcon

# Proton Fix machine-id
RUN         rm -f /etc/machine-id
RUN         dbus-uuidgen --ensure=/etc/machine-id
RUN         rm /var/lib/dbus/machine-id
RUN         dbus-uuidgen --ensure


RUN     dpkg --add-architecture armhf

RUN     apt-get update \
        && apt-get install --yes --no-install-recommends libc6:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf libc6:armhf libncurses5:armhf libpulse0:armhf libpulse-dev:armhf libatomic1:armhf \
        && apt-get -y autoremove\
        && apt update \
        && apt-get clean autoclean \
        && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists
				
RUN     apt-get update && apt-get install -y apt-transport-https

RUN     apt install -y libc++-dev libc6 git wget tar zip unzip binutils xz-utils liblzo2-2 cabextract iproute2 net-tools libatomic1 libsdl1.2debian libsdl2-2.0-0 \
        libfontconfig icu-devtools libunwind8 libssl-dev sqlite3 libsqlite3-dev libmariadbclient-dev-compat  locales ffmpeg gnupg2 apt-transport-https software-properties-common ca-certificates \
        libz-dev rapidjson-dev tzdata libevent-dev libzip4 libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 build-essential cmake libgdiplus libpulse0 libpulse-dev libatomic1 netcat \
        libflashrom1 libftdi1-2 telnet tini screen libxi6 xvfb

## failing to install
# RUN     apt update \
#         && apt install -y libicu67 libduktape205

RUN     update-locale lang=en_US.UTF-8 \
         && dpkg-reconfigure --frontend noninteractive locales

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]
