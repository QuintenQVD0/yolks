FROM        --platform=$TARGETOS/$TARGETARCH alpine:latest

RUN         apk add --update --no-cache ca-certificates tzdata busybox-binsh libevent libsasl libseccomp musl \
				&& adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/ash", "/entrypoint.sh" ]
