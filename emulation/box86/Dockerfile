FROM debian:bookworm-slim


RUN		dpkg --add-architecture armhf

RUN		apt update \
        && apt install -y wget gnupg2 \
		&& wget -qO- "https://pi-apps-coders.github.io/box86-debs/KEY.gpg" | gpg --dearmor -o /usr/share/keyrings/box86-archive-keyring.gpg \
        && printf "Types: deb\nURIs: https://Pi-Apps-Coders.github.io/box86-debs/debian\nSuites: ./\nSigned-By: /usr/share/keyrings/box86-archive-keyring.gpg\n" > /etc/apt/sources.list.d/box86.sources \
		&& apt update && apt install box86-generic-arm:armhf libc6 libc6:armhf -y

RUN dpkg --add-architecture armhf && \
    apt-get update && \
    apt-get install --yes --no-install-recommends libc6:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf libc6:armhf libncurses5:armhf netcat && \
    apt-get -y autoremove && \
    apt-get clean autoclean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists
	
RUN         dpkg --add-architecture i386 \
            && apt update \
            && apt upgrade -y \
			&& apt install -y libtbb2:i386 libtbb-dev:i386 libicu-dev:i386 libstdc++6 dnsutils libsdl2-2.0-0
			
RUN 		 apt-get update && apt-get install -y apt-transport-https
RUN          apt install -y libc++-dev libc6 git wget curl tar zip unzip binutils xz-utils liblzo2-2 cabextract iproute2 net-tools libatomic1 libsdl1.2debian libsdl2-2.0-0 \
             libfontconfig libicu67 icu-devtools libunwind8 libssl-dev sqlite3 libsqlite3-dev libmariadbclient-dev-compat libduktape205 locales ffmpeg gnupg2 apt-transport-https software-properties-common ca-certificates \
             libz-dev rapidjson-dev tzdata libevent-dev libzip4 libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 build-essential cmake libgdiplus tini

RUN     update-locale lang=en_US.UTF-8 \
        && dpkg-reconfigure --frontend noninteractive locales

ENV     STEAMOS=1
ENV     STEAM_RUNTIME=1
ENV     DBUS_FATAL_WARNINGS=0

RUN		useradd -d /home/container -m container
USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
