FROM        node:18


RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -d /home/container -m container -s /bin/bash


RUN         apt update \
            && apt -y install ffmpeg iproute2 git sqlite3 libsqlite3-dev python3 python3-dev ca-certificates dnsutils tzdata zip tar curl build-essential wget apt-transport-https lsb-release libtool 

RUN         npm install npm@9.8.1 typescript ts-node @types/node --location=global   

RUN		echo "deb https://notesalexp.org/tesseract-ocr5/$(lsb_release -cs)/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/notesalexp.list > /dev/null \
		&& wget -O - https://notesalexp.org/debian/alexp_key.asc | apt-key add - \
		&& apt update \
		&& apt -y install tesseract-ocr


RUN   apt update \
			&& apt -y install curl tar bzip2 file wget \
      && wget https://dot.net/v1/dotnet-install.sh \
			&& mkdir -p /usr/share \
      && chmod +x dotnet-install.sh \
			&& D_V="$(curl -sSL https://dotnet.microsoft.com/en-us/download/dotnet/7.0 | grep -i  '<h3 id="sdk-7.*">SDK 7.*.*</h3>'  | head -1 | awk -F\" '{print $3}' | awk '{print $2;}' | sed 's/<\/h3>//g')" \
			&& echo $D_V \			
			&& ./dotnet-install.sh -i /usr/share -v $D_V \
			&& ln -s /usr/share/dotnet /usr/bin/dotnet 
      
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD     ["/bin/bash", "/entrypoint.sh"]
