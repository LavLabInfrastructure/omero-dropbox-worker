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
    gawk \
    unzip \
    coreutils \
    curl \
    default-jre-headless \
    && rm -rf /var/lib/apt/lists/*

COPY --from=pybuilder /opt/venv /opt/venv

COPY --from=unzip /opt/bioformats2raw-0.9.1 /opt/bioformats2raw-0.9.1
COPY --from=unzip /opt/raw2ometiff-0.7.0 /opt/raw2ometiff-0.7.0

# Update PATH environment variable
ENV PATH="/opt/venv/bin:/opt/bioformats2raw-0.9.1/bin:/opt/raw2ometiff-0.7.0/bin:${PATH}"
ENV HOME=/tmp
ENV JAVA_TOOL_OPTIONS="-Djava.util.prefs.userRoot=/tmp/.java/.userPrefs"
USER 1000
RUN /bin/bash -c 'omero import -s "w" -p 4064 -u fake -w fake; exit 0'
# Download and install OMERO.java.zip to the correct location
RUN OMERO_USER_CACHE_DIR=/tmp/.cache/OMERO.py/5/ \
    && mkdir -p $OMERO_USER_CACHE_DIR/jars \
    && curl -Lo /tmp/omero.java.zip https://downloads.openmicroscopy.org/omero/5.6.16/artifacts/OMERO.java-5.6.16-ice36.zip \
    && unzip /tmp/omero.java.zip -d $OMERO_USER_CACHE_DIR/jars \
    && topdir=$(unzip -l /tmp/omero.java.zip | awk '/\/$/ {print $4}' | head -n 1 | cut -d/ -f1) \
    && echo "$topdir" > $OMERO_USER_CACHE_DIR/jars/OMERO.java.txt \
    && rm /tmp/omero.java.zip
