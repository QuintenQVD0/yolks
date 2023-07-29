FROM        --platform=$TARGETOS/$TARGETARCH debian:bullseye-slim

ENV         DEBIAN_FRONTEND=noninteractive

RUN 			apt update
				&& apt upgrade -y \
				&& apt -y --no-install-recommends install ca-certificates curl git unzip zip tar jq wget


RUN         ARCH=$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64") \
            && $([ "$ARCH" = "amd64" ] && { dpkg --add-architecture i386;  apt update; apt -y install lib32gcc-s1 libsdl2-2.0-0:i386;} )
