FROM  debian:bookworm-slim

ENV       DEBIAN_FRONTEND=noninteractive

RUN useradd -m -d /home/container -s /bin/bash container
RUN echo 'deb http://security.debian.org/debian-security bookworm-security main' | tee -a /etc/apt/sources.list
## install required packages
RUN dpkg --add-architecture i386 \
            && apt update -y \
            && apt install -y --no-install-recommends \
                gnupg2 iproute2 wget numactl tzdata software-properties-common \
                libntlm0 winbind xvfb xauth python3 python3-pip libncurses5:i386 libncurses6:i386 libsdl2-2.0-0 libsdl2-2.0-0:i386 \
                tightvncserver x11-xserver-utils xfonts-base debian-keyring debian-archive-keyring apt-transport-https \
                curl xloadimage novnc java-common p7zip-full \
            && apt clean \
            && rm -rf /var/lib/apt/lists/*


# Install wine 10.1 and with recommends
RUN             mkdir -pm755 /etc/apt/keyrings
RUN             wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN             wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
RUN             apt update
RUN             apt install --install-recommends wine-staging-i386=10.1~bookworm-1 -y && \
                apt install --install-recommends wine-staging-amd64=10.1~bookworm-1 -y && \
                apt install --install-recommends wine-staging=10.1~bookworm-1 -y && \
                apt install --install-recommends winehq-staging=10.1~bookworm-1 -y && \
                apt install --install-recommends cabextract wine-binfmt -y
RUN             apt install -y firefox-esr openbox
RUN             rm -rf /var/lib/apt/lists/*
RUN             update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 500
RUN             update-alternatives --set x-www-browser /usr/bin/firefox
# Set up legendary
RUN	            wget -q -O /usr/sbin/legendary https://github.com/legendary-gl/legendary/releases/download/0.21.0/legendary_linux_x64 \
                && chmod +x /usr/sbin/legendary


RUN             wget -q -O zulu_21.deb https://cdn.azul.com/zulu/bin/zulu21.54.109-ca-jre21.0.13.0.3-linux_amd64.deb \
                && dpkg -i zulu_21.deb \
                && rm zulu_21.deb

ENV         WINEPREFIX=/home/container/.wine
ENV         WINEDLLOVERRIDES="mscoree=d,mshtml="
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container


ADD         FarmingSimulator25.png /FarmingSimulator25.png
ADD         rc.xml /rc.xml
ADD         license-key-validator.jar /license-key-validator.jar
ADD         index.html /usr/share/novnc/index.html
ADD         entrypoint.sh /entrypoint.sh
CMD             [ "/bin/bash", "/entrypoint.sh" ]
