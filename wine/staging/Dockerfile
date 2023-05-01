FROM    ghcr.io/parkervcp/yolks:debian

LABEL       author="QuintenQVD" maintainer="josdekurk@gmail.com"

## install required packages
RUN     dpkg --add-architecture i386 \
        && apt update -y \
        && apt install -y --no-install-recommends gnupg2 tzdata software-properties-common libntlm0 winbind xvfb xauth python3
# Install winehq-stable and with recommends
RUN     wget -nc https://dl.winehq.org/wine-builds/winehq.key \
        && apt-key add winehq.key \
        && echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" >> /etc/apt/sources.list \
        && wget -O- -q download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_11/Release.key | apt-key add - \
        && echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_11 ./" | tee /etc/apt/sources.list.d/wine-obs.list \
        && apt update \
	&& apt install -y --install-recommends winehq-staging cabextract

# Set up Winetricks
RUN	    wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
        && chmod +x /usr/sbin/winetricks

## install rcon
RUN         cd /tmp/ \
            && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
            && tar xvf rcon.tar.gz \
            && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/
            
ENV     HOME=/home/container
ENV     WINEPREFIX=/home/container/.wine
ENV     WINEDLLOVERRIDES="mscoree,mshtml="
ENV     DISPLAY=:0
ENV     DISPLAY_WIDTH=1024
ENV     DISPLAY_HEIGHT=768
ENV     DISPLAY_DEPTH=16
ENV     AUTO_UPDATE=1
ENV     XVFB=1

USER    container
WORKDIR	/home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD	    ["/bin/bash", "/entrypoint.sh"]
