FROM ubuntu:20.04

ENV   DEBIAN_FRONTEND noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container


RUN     apt update && apt -y install software-properties-common \
        && add-apt-repository ppa:openjdk/ppa \
        && apt update \
        && apt -y install openjdk-7 

RUN     apt update \
        && apt -y install curl git iproute2 tar tzdata tar libssl1.1 

WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]
