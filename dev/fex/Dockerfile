FROM --platform=linux/arm64 ubuntu:22.04

ENV   DEBIAN_FRONTEND=noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container

RUN     apt update && apt -y install software-properties-common wget curl fuse squashfs-tools zenity libsdl2-2.0-0 libepoxy0 libgl1 squashfuse binfmt-support
RUN     apt update
RUN     wget https://raw.githubusercontent.com/QuintenQVD0/yolks/refs/heads/master/dev/fex-emu-armv8.0_2312.1~l_arm64.deb
RUN     dpkg -i fex-emu-armv8.0_2312.1~l_arm64.deb
RUN     wget https://raw.githubusercontent.com/QuintenQVD0/yolks/refs/heads/master/dev/fex-emu-binfmt32_2312.1~l_arm64.deb
RUN     dpkg -i fex-emu-binfmt32_2312.1~l_arm64.deb
RUN     wget https://raw.githubusercontent.com/QuintenQVD0/yolks/refs/heads/master/dev/fex-emu-binfmt64_2312.1~l_arm64.deb
RUN     dpkg -i fex-emu-binfmt64_2312.1~l_arm64.deb

RUN	apt update \ 
        && apt -y install curl git iproute2 libssl-dev squashfuse fuse squashfs-tools tzdata tar wget zip build-essential unzip gdb gettext screen numactl libc6 libstdc++6 \
	&& wget http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
  	&& dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
        && ls -la /usr/local/bin

		
RUN     wget https://github.com/QuintenQVD0/rcon-cli/releases/latest/download/gorcon-linux-arm64  -O /usr/local/bin/rcon \
	&& chmod +x /usr/local/bin/rcon

WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]
