FROM    ghcr.io/parkervcp/yolks:debian

## install required packages
RUN     dpkg --add-architecture i386 \
        && apt update -y \
        && apt install -y --no-install-recommends jq gnupg2 tzdata numactl python3 software-properties-common libntlm0 winbind xvfb xauth python3 libncurses5:i386 libncurses6:i386 libsdl2-2.0-0 libsdl2-2.0-0:i386

# Install PROTON and with recommends
RUN     DOWNLOAD_URL=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | jq .assets | jq -r .[].browser_download_url | grep -i tar.gz | head -1) \
        && echo ${DOWNLOAD_URL} \
        && mkdir -p /tmp/download  && mkdir /usr/local/bin/proton \
        && cd /tmp/download && ls -la\
        && curl --progress-bar -sSL -o GE-Proton.tar.gz ${DOWNLOAD_URL} && ls -la \
        && tar -xvf GE-Proton.tar.gz --strip-components=1 -C /usr/local/bin/proton \
        && ls -la /usr/local/bin \
        && ls -la /usr/local/bin/proton \
        && export PATH=/usr/local/bin/proton:$PATH


# Set up Winetricks
RUN	    wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
        && chmod +x /usr/sbin/winetricks

ENV     PATH=/usr/local/bin/proton:$PATH
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

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
