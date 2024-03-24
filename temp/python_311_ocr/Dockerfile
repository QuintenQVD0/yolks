FROM        --platform=$TARGETOS/$TARGETARCH python:3.11-slim

LABEL       author="Michael Parker" maintainer="parker@pterodactyl.io"

RUN         apt update \
            && apt -y install git gcc g++ ca-certificates dnsutils curl iproute2 ffmpeg procps tini wget gnupg aptitude \
            && useradd -m -d /home/container container

RUN         apt install apt-transport-https \
            && echo "deb https://notesalexp.org/tesseract-ocr5/bookworm/ bookworm main" >> /etc/apt/sources.list \
            && wget -O - https://notesalexp.org/debian/alexp_key.asc | apt-key add - \
            && apt-get update \
            && aptitude -y install tesseract-ocr

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
