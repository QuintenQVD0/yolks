FROM        --platform=$TARGETOS/$TARGETARCH alpine:edge


RUN         apk add --update --no-cache ca-certificates curl ffmpeg git openssl sqlite tar tzdata minetest \
				&& adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/ash", "/entrypoint.sh" ]