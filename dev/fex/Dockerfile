FROM --platform=linux/arm64 ubuntu:22.04

ENV   DEBIAN_FRONTEND noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container


RUN     apt update && apt -y install software-properties-common \
        && add-apt-repository ppa:fex-emu/fex \
        && apt update \
        && apt -y install fex-emu-armv8.2 fex-emu-binfmt32 fex-emu-binfmt64

RUN	apt update \ 
        && apt -y install curl git iproute2 libssl-dev squashfuse fuse squashfs-tools tzdata tar wget zip build-essential unzip gdb libnss-wrapper gettext \
	&& wget http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
  	&& dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
        && ls -la /usr/local/bin

## Prepare NSS Wrapper for the entrypoint as a workaround for Valheim requiring a valid UID
ENV         NSS_WRAPPER_PASSWD=/tmp/passwd NSS_WRAPPER_GROUP=/tmp/group
RUN         touch ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chgrp 0 ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chmod g+rw ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP}
ADD         passwd.template /passwd.template

WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]
