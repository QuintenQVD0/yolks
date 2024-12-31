FROM       --platform=$TARGETOS/$TARGETARCH quintenqvd/pterodactyl_images:installer_steamcmd

## install required packages
RUN         apt update
RUN         apt install -y --no-install-recommends software-properties-common libntlm0 winbind xauth libncurses6 dbus libgdiplus wget
RUN         apt install -y alsa-tools pulseaudio libasound2 libao-common gnutls-bin gnupg numactl curl python3 python3-pip python3-setuptools

RUN         useradd -d /home/container -m container
RUN     wget https://github.com/QuintenQVD0/rcon-cli/releases/latest/download/gorcon-linux-arm64  -O /usr/local/bin/rcon \
	&& chmod +x /usr/local/bin/rcon

# Download Proton GE
RUN         curl -sLOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)"
RUN         tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1
RUN         rm GE-Proton*.*

# Proton Fix machine-id
RUN         rm -f /etc/machine-id
RUN         dbus-uuidgen --ensure=/etc/machine-id
RUN         rm /var/lib/dbus/machine-id
RUN         dbus-uuidgen --ensure

## copied from emulation
RUN     apt-get update \
        && apt-get install --yes --no-install-recommends libc6:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf libc6:armhf libncurses5:armhf libpulse0:armhf libpulse-dev:armhf libatomic1:armhf \
        && apt-get -y autoremove\
        && apt update \
        && apt-get clean autoclean \
        && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists
				
RUN 		 apt-get update && apt-get install -y apt-transport-https

RUN          apt install -y libc++-dev libc6 git tar zip unzip binutils xz-utils liblzo2-2 cabextract iproute2 net-tools libatomic1 libsdl1.2debian libsdl2-2.0-0 \
             libfontconfig libicu72 icu-devtools libunwind8 libssl-dev sqlite3 libsqlite3-dev libmariadbclient-dev-compat libduktape207 locales ffmpeg gnupg2 apt-transport-https software-properties-common ca-certificates \
             libz-dev rapidjson-dev tzdata libevent-dev libzip4 libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 build-essential cmake libgdiplus libpulse0 libpulse-dev libatomic1 netcat-openbsd \
             libflashrom1 libftdi1-2 telnet tini screen libxi6 xvfb

RUN     update-locale lang=en_US.UTF-8 \
        && dpkg-reconfigure --frontend noninteractive locales

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
