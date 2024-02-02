FROM eclipse-temurin:8-jre-jammy

RUN apt-get update && apt-get install -y unzip libssl-dev libbz2-dev libblosc1 python3 python3-pip python3-setuptools python3-wheel

RUN pip3 install --no-cache-dir omero-py

RUN mkdir /tmp/bin
RUN curl -Lo /tmp/bf2raw.zip https://github.com/glencoesoftware/bioformats2raw/releases/download/v0.9.1/bioformats2raw-0.9.1.zip
RUN unzip /tmp/bf2raw.zip -d /tmp/bin
RUN curl -Lo /tmp/raw2ometiff.zip https://github.com/glencoesoftware/raw2ometiff/releases/download/v0.7.0/raw2ometiff-0.7.0.zip
RUN unzip /tmp/raw2ometiff.zip -d /tmp/bin

RUN mv /tmp/bin/bioformats*/bin/* /tmp/bin/raw*/bin/* /usr/local/bin
RUN mv -f /tmp/bin/bioformats*/lib/* /tmp/bin/raw*/lib/* /usr/local/lib

RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/* 

USER 1000
