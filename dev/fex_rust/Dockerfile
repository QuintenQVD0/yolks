FROM --platform=linux/arm64 ubuntu:22.04

ENV   DEBIAN_FRONTEND=noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container


RUN     apt update && apt -y install software-properties-common wget curl fuse squashfs-tools zenity libsdl2-2.0-0 libepoxy0 libgl1 squashfuse binfmt-support \
        && apt update \
        && wget https://raw.githubusercontent.com/QuintenQVD0/yolks/refs/heads/master/dev/fex-emu-armv8.0_2312.1~l_arm64.deb \
        && dpkg -i fex-emu-armv8.0_2312.1~l_arm64.deb \
        && wget https://raw.githubusercontent.com/QuintenQVD0/yolks/refs/heads/master/dev/fex-emu-binfmt32_2312.1~l_arm64.deb \
        && dpkg -i fex-emu-binfmt32_2312.1~l_arm64.deb \
        && wget https://raw.githubusercontent.com/QuintenQVD0/yolks/refs/heads/master/dev/fex-emu-binfmt64_2312.1~l_arm64.deb \
        && dpkg -i fex-emu-binfmt64_2312.1~l_arm64.deb

RUN		apt update \ 
        && apt -y install curl git iproute2 libssl-dev squashfuse fuse squashfs-tools tzdata tar wget zip build-essential unzip \
		&& wget http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
  		&& dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
        && ls -la /usr/local/bin \
		&& curl -sL https://deb.nodesource.com/setup_14.x | bash - \
		&& apt install -y nodejs \
		&& mkdir /node_modules \
		&& npm install --prefix / ws 
  
WORKDIR /home/container

COPY 		./wrapper.js /wrapper.js
COPY  ./entrypoint.sh /entrypoint.sh

CMD   [ "/bin/bash", "/entrypoint.sh" ]
