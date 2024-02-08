FROM python:3.10-slim-bookworm as pybuilder

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libbz2-dev

RUN python3 -m venv /opt/venv && /opt/venv/bin/pip install --upgrade pip
RUN /opt/venv/bin/pip install omero-py

FROM python:3.10-slim-bookworm as unzip
RUN apt-get update && apt-get install -y unzip curl 

RUN curl -Lo /tmp/bf2raw.zip https://github.com/glencoesoftware/bioformats2raw/releases/download/v0.9.1/bioformats2raw-0.9.1.zip && \
    unzip /tmp/bf2raw.zip -d /opt && \
    curl -Lo /tmp/raw2ometiff.zip https://github.com/glencoesoftware/raw2ometiff/releases/download/v0.7.0/raw2ometiff-0.7.0.zip && \
    unzip /tmp/raw2ometiff.zip -d /opt

FROM python:3.10-slim-bookworm as final
RUN apt-get update && apt-get install -y \
    libblosc1 \
    default-jre-headless \
    && rm -rf /var/lib/apt/lists/*

COPY --from=pybuilder /opt/venv /opt/venv

COPY --from=unzip /opt/bioformats2raw-0.9.1 /opt/bioformats2raw-0.9.1
COPY --from=unzip /opt/raw2ometiff-0.7.0 /opt/raw2ometiff-0.7.0

# Update PATH environment variable
ENV PATH="/opt/venv/bin:/opt/bioformats2raw-0.9.1/bin:/opt/raw2ometiff-0.7.0/bin:${PATH}"
USER 1000
