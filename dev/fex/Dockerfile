FROM --platform=linux/arm64 golang:1.21.6-bookworm as builder

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
        && apt -y install fex-emu-binfmt32 fex-emu-binfmt64 fex-emu-armv8.0

RUN	apt update \ 
        && apt -y install curl git iproute2 libssl-dev squashfuse fuse squashfs-tools tzdata tar wget zip build-essential unzip gdb gettext screen numactl libc6 libstdc++6 \
	&& wget http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
  	&& dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
        && ls -la /usr/local/bin


WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]
