FROM        --platform=$TARGETOS/$TARGETARCH eclipse-temurin:17-jdk-focal


RUN         apt update -y \
						&& apt install -y curl lsof ca-certificates openssl git tar sqlite3 fontconfig tzdata iproute2 libfreetype6 libgtk-3-0 firefox-geckodriver \
						&& useradd -d /home/container -m container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
