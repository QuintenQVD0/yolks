FROM --platform=linux/arm64 ubuntu:22.04

ENV   DEBIAN_FRONTEND=noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container

RUN     apt update && apt -y install software-properties-common wget curl fuse squashfs-tools zenity libsdl2-2.0-0 libepoxy0 libgl1 squashfuse binfmt-support \
        && apt update \
        && apt -y install qml-module-qtquick-controls qml-module-qtquick-controls2 qml-module-qtquick-dialogs libqt5core5a libqt5gui5 libqt5qml5 libqt5quick5 libqt5widgets5 \
        && wget https://ppa.launchpadcontent.net/fex-emu/fex/ubuntu/pool/main/f/fex-emu-armv8.0/fex-emu-armv8.0_2510~1~j_arm64.deb \
		&& dpkg -i fex-emu-armv8.0_2510~1~j_arm64.deb && rm fex-emu-armv8.0_2510~1~j_arm64.deb \
        && mkdir -p /usr/lib/binfmt.d && cd /usr/lib/binfmt.d \
        && echo ":FEX-x86_64:M:0:\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00:\xff\xff\xff\xff\xff\xfe\xfe\x00\x00\x00\x00\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/FEXInterpreter:POCF" > FEX-x86_64.conf \
        && echo ":FEX-x86:M:0:\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03\x00:\xff\xff\xff\xff\xff\xfe\xfe\x00\x00\x00\x00\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/FEXInterpreter:POCF" > FEX-x86.conf        

RUN	apt update \ 
        && apt -y install curl git iproute2 libssl-dev squashfuse fuse squashfs-tools tzdata tar zip build-essential unzip gdb gettext screen numactl libc6 libstdc++6 \
		&& wget http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
  		&& dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
        && ls -la /usr/local/bin

RUN     wget https://github.com/QuintenQVD0/rcon-cli/releases/latest/download/gorcon-linux-arm64  -O /usr/local/bin/rcon \
	&& chmod +x /usr/local/bin/rcon

WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]
