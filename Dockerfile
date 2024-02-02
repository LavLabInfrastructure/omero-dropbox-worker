FROM alpine:3.17 as  pybuilder
RUN apk add --no-cache musl-dev linux-headers g++ openssl-dev bzip2-dev python3-dev
RUN python3 -m venv /opt/venv && /opt/venv/bin/pip install --upgrade pip
RUN /opt/venv/bin/python3 -m pip install omero-py

FROM alpine:3.19 as unzip
RUN apk add --no-cache unzip 
RUN wget -O /tmp/bf2raw.zip https://github.com/glencoesoftware/bioformats2raw/releases/download/v0.9.1/bioformats2raw-0.9.1.zip
RUN unzip /tmp/bf2raw.zip -d /tmp
RUN wget -O /tmp/raw2ometiff.zip https://github.com/glencoesoftware/raw2ometiff/releases/download/v0.7.0/raw2ometiff-0.7.0.zip
RUN unzip /tmp/raw2ometiff.zip -d /tmp

FROM alpine:3.19 as final
RUN apk add --no-cache blosc python3
COPY --from=pybuilder /opt/venv /opt
COPY --from=unzip /tmp/bioformats2raw-0.9.1 /opt/bioformats2raw-0.9.1
COPY --from=unzip /tmp/raw2ometiff-0.7.0 /opt/raw2ometiff-0.7.0

ENV PATH="/opt/venv/bin:/opt/bioformats2raw-0.9.1:/opt/raw2ometiff-0.7.0:${PATH}"
