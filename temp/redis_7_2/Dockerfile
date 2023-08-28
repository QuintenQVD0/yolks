FROM    --platform=$TARGETOS/$TARGETARCH redis:7.2-bookworm

ENV     DEBIAN_FRONTEND noninteractive

RUN     apt -y update && \
        apt -y upgrade && \
        apt -y install iproute2 tar curl tzdata tini unzip && \
        useradd -d /home/container -m container -s /bin/bash

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]