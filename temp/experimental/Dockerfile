FROM  debian:bookworm-slim

ENV       DEBIAN_FRONTEND=noninteractive

RUN useradd -m -d /home/container -s /bin/bash container 

## install required packages
RUN             dpkg --add-architecture i386 \
                && apt update -y \
                && apt install -y --no-install-recommends gnupg2 iproute2 wget numactl tzdata software-properties-common libntlm0 winbind xvfb xauth python3 libncurses5:i386 libncurses6:i386 libsdl2-2.0-0 libsdl2-2.0-0:i386 tightvncserver x11-xserver-utils xfonts-base debian-keyring debian-archive-keyring apt-transport-https curl xloadimage novnc

# Install wine staging
RUN             mkdir -pm755 /etc/apt/keyrings
RUN             wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN             wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
RUN             apt update
RUN             apt install --install-recommends winehq-staging cabextract wine-binfmt -y
RUN             apt install -y surf openbox
RUN             rm -rf /var/lib/apt/lists/*

# Set up Winetricks
RUN	            wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
                && chmod +x /usr/sbin/winetricks

# Download custom reverse proxy to allow the web dashboard to be avaible to the public
RUN            wget -q -O /usr/sbin/reverse_proxy_linux_x64 https://github.com/QuintenQVD0/fs-reverse-proxy/releases/download/v1.0.0/reverse_proxy_linux_x64 \
               && chmod +x /usr/sbin/reverse_proxy_linux_x64

       
ENV         WINEPREFIX=/home/container/.wine
ENV         WINEDLLOVERRIDES="mscoree=d,mshtml="
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container


ADD         FarmingSimulator25.png /FarmingSimulator25.png
ADD         index.html /usr/share/novnc/index.html
ADD         entrypoint.sh /entrypoint.sh
CMD             [ "/bin/bash", "/entrypoint.sh" ]
