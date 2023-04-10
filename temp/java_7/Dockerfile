FROM debian:bullseye-slim

ENV   DEBIAN_FRONTEND noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container


RUN     apt update && apt -y install software-properties-common wget java-common libxtst6  \
        && wget https://cdn.azul.com/zulu/bin/zulu7.56.0.11-ca-jdk7.0.352-linux_amd64.deb -O java.deb \
        && dpkg -i java.deb \
        && rm java.deb \
        && apt update \
        && apt -y install zulu-7

RUN     apt update \
        && apt -y install curl git iproute2 tar tzdata tar libssl1.1 

WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]
