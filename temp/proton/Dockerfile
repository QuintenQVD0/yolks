FROM        --platform=$TARGETOS/$TARGETARCH debian:bullseye-slim


ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y tar curl gcc wget g++ lib32gcc-s1 alsa-utils pulseaudio python3 libgcc1 libcurl4-gnutls-dev:i386 libssl1.1:i386 libcurl4:i386 lib32tinfo6 libtinfo6:i386 lib32z1 lib32stdc++6 libncurses5:i386 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 libsdl2-2.0-0 iproute2 gdb libsdl1.2debian libfontconfig1 telnet net-tools netcat tzdata numactl xvfb \
            && useradd -m -d /home/container container
			
## install rcon
RUN         cd /tmp/ \
            && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.2/rcon-0.10.2-amd64_linux.tar.gz > rcon.tar.gz \
            && tar xvf rcon.tar.gz \
            && mv rcon-0.10.2-amd64_linux/rcon /usr/local/bin/
# Set up Winetricks
RUN	    	wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
        	&& chmod +x /usr/sbin/winetricks
		
RUN         rm -f /etc/machine-id
RUN         dbus-uuidgen --ensure=/etc/machine-id
RUN         rm /var/lib/dbus/machine-id
RUN         dbus-uuidgen --ensure

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
