FROM --platform=linux/arm64 golang:1.19.3-bullseye as builder

RUN 	apt update \
		&& apt install -y git curl gcc musl-dev

RUN 	git clone https://github.com/gorcon/rcon-cli.git \
		&& cd rcon-cli/ \
		&& go get -v -t -d ./... \
		&& CGO_ENABLED=1 go build -ldflags "-s -w -X main.ServiceVersion=docker" -v ./cmd/gorcon \
		&& mv gorcon /tmp/rcon

FROM --platform=linux/arm64 ubuntu:22.04

ENV   DEBIAN_FRONTEND=noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container

COPY --from=builder /tmp/rcon /usr/local/bin/rcon

RUN     apt update && apt -y install software-properties-common wget curl fuse squashfs-tools zenity libsdl2-2.0-0 libepoxy0 libgl1 squashfuse \
        && add-apt-repository ppa:fex-emu/fex \
        && apt update \
        && wget https://ppa.launchpadcontent.net/fex-emu/fex/ubuntu/pool/main/f/fex-emu-armv8.0/fex-emu-armv8.0_2312.1~l_arm64.deb \
        && dpkg -i fex-emu-armv8.0_2312.1~l_arm64.deb \
        && apt -y install fex-emu-binfmt32 fex-emu-binfmt64

RUN	apt update \ 
        && apt -y install curl git iproute2 libssl-dev squashfuse fuse squashfs-tools tzdata tar wget zip build-essential unzip gdb gettext screen numactl libc6 libstdc++6 \
	&& wget http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
  	&& dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
        && ls -la /usr/local/bin

## install required packages
RUN         apt update
RUN         apt install -y --no-install-recommends software-properties-common libntlm0 winbind xauth libncurses6 dbus libgdiplus
RUN         apt install -y alsa-tools pulseaudio libasound2 libao-common gnutls-bin gnupg numactl curl python3 python3-pip python3-setuptools

COPY --from=builder /tmp/rcon /usr/local/bin/rcon

# Download Proton GE
RUN         curl -sLOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)"
RUN         tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1
RUN         rm GE-Proton*.*

# Proton Fix machine-id
RUN         rm -f /etc/machine-id
RUN         dbus-uuidgen --ensure=/etc/machine-id
RUN         rm /var/lib/dbus/machine-id
RUN         dbus-uuidgen --ensure

WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]
