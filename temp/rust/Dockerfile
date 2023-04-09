FROM 		--platform=$TARGETOS/$TARGETARCH python:3.11-slim-bullseye


ENV         DEBIAN_FRONTEND=noninteractive

RUN			dpkg --add-architecture i386 \
			&& apt update \
			&& apt upgrade -y \
			&& apt install -y lib32gcc-s1 lib32stdc++6 unzip curl iproute2 tzdata libgdiplus libsdl2-2.0-0:i386 \
			&& python3 -m pip install websocket \
			&& useradd -d /home/container -m container

USER 		container
ENV  		USER=container HOME=/home/container

WORKDIR 	/home/container

COPY 		./entrypoint.sh /entrypoint.sh
COPY 		./wrapper.py /wrapper.py

CMD			[ "/bin/bash", "/entrypoint.sh" ]
