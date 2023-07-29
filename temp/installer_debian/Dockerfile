FROM        --platform=$TARGETOS/$TARGETARCH debian:bullseye-slim
ENV         DEBIAN_FRONTEND=noninteractive

RUN      apt update && apt upgrade -y \
         && apt -y --no-install-recommends install ca-certificates curl git unzip zip tar jq wget

# Set the ARCH variable based on the platform
RUN     ARCH=$(uname -m); \
            if [ "$ARCH" = "x86_64" ]; then \
                dpkg --add-architecture i386 && \
                apt update && \
                apt -y install lib32gcc-s1 libsdl2-2.0-0:i386; \
            fi

