FROM --platform=linux/arm64 ubuntu:22.04

ENV   DEBIAN_FRONTEND noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container


RUN     apt update && apt -y install software-properties-common \
        && add-apt-repository ppa:fex-emu/fex \
        && apt update \
        && apt -y install fex-emu-armv8.2 fex-emu-binfmt32 fex-emu-binfmt64

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
