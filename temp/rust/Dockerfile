FROM 		--platform=$TARGETOS/$TARGETARCH debian:bullseye-slim


ENV         DEBIAN_FRONTEND=noninteractive

RUN			dpkg --add-architecture i386 \
			&& apt update \
			&& apt upgrade -y \
			&& apt install -y lib32gcc-s1 lib32stdc++6 unzip curl iproute2 tzdata libgdiplus libsdl2-2.0-0:i386 tar sqlite3 libsqlite3-0 \
			&& useradd -d /home/container -m container


## install rcon
RUN         cd /tmp/ \
            && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
            && tar xvf rcon.tar.gz \
            && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/
			
WORKDIR 	/home/container
USER 		container
ENV  		USER=container HOME=/home/container

COPY 		./entrypoint.sh /entrypoint.sh

CMD			[ "/bin/bash", "/entrypoint.sh" ]
