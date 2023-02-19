FROM        --platform=$TARGETOS/$TARGETARCH alpine:edge

ENV         DEBIAN_FRONTEND noninteractive

RUN         apk add --update --no-cache ca-certificates curl ffmpeg git openssl minetest sqlite tar tzdata \
				&& adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/ash", "/entrypoint.sh" ]