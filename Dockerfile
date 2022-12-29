# healthz image
FROM ghcr.io/binkhq/healthz:2022-03-11T125439Z as healthz

# Debian Builder image
FROM ghcr.io/illallangi/debian:v0.0.9 AS debian-builder

RUN \
  apt-get update \
  && \
  apt-get install -y --no-install-recommends \
    build-essential=12.6 \
    gcc=4:8.3.0-1 \
    make=4.2.1-1.2 \
  && \
  rm -rf /var/lib/apt/lists/*

# Build cfssl
FROM debian-builder AS cfssl-builder

RUN \
  curl https://github.com/cloudflare/cfssl/releases/download/v1.6.2/cfssl_1.6.2_linux_amd64 --location --output /usr/local/bin/cfssl \
  && \
  chmod +x \
    /usr/local/bin/cfssl

# Build cfssljson
FROM debian-builder AS cfssljson-builder

RUN \
  curl https://github.com/cloudflare/cfssl/releases/download/v1.6.2/cfssljson_1.6.2_linux_amd64 --location --output /usr/local/bin/cfssljson \
  && \
  chmod +x \
    /usr/local/bin/cfssljson

# Build dumb-init
FROM debian-builder as dumb-init-builder

RUN \
  curl "https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_$(uname -m)" --location --output /usr/local/bin/dumb-init \
  && \
  chmod +x \
    /usr/local/bin/dumb-init

# Build gosu
FROM debian-builder as gosu-builder

RUN \
  curl https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64 --location --output /usr/local/bin/gosu \
  && \
  chmod +x \
    /usr/local/bin/gosu

# Build restic
FROM debian-builder AS restic-builder

RUN \
  curl https://github.com/restic/restic/releases/download/v0.14.0/restic_0.14.0_linux_amd64.bz2 --location --output /usr/local/src/restic.bz2 \
  && \
  bzip2 --decompress --keep /usr/local/src/restic.bz2 \
  && \
  mv /usr/local/src/restic /usr/local/bin/restic \
  && \
  chmod +x \
    /usr/local/bin/restic

# Build mktorrent
FROM debian-builder AS mktorrent-builder

RUN \
  mkdir -p /usr/local/src/mktorrent \
  && \
  curl https://github.com/pobrn/mktorrent/archive/master.tar.gz --location --output /usr/local/src/mktorrent.tar.gz \
  && \
  tar --gzip --extract --verbose --directory /usr/local/src/mktorrent --strip-components=1 --file /usr/local/src/mktorrent.tar.gz \
  && \
  make install --directory /usr/local/src/mktorrent

# Build whatmp3
FROM debian-builder as whatmp3-builder

RUN \
  mkdir -p /usr/local/src/whatmp3 \
  && \
  curl https://github.com/RecursiveForest/whatmp3/archive/master.tar.gz --location --output /usr/local/src/whatmp3.tar.gz \
  && \
  tar --gzip --extract --verbose --directory /usr/local/src/whatmp3 --strip-components=1 --file /usr/local/src/whatmp3.tar.gz \
  && \
  cp /usr/local/src/whatmp3/whatmp3.py /usr/local/bin/whatmp3

# Build yacron
FROM debian-builder as yacron-builder
RUN \
  curl "https://github.com/gjcarneiro/yacron/releases/download/0.16.0/yacron-0.16.0-$(uname -m)-unknown-linux-gnu" --location --output /usr/local/bin/yacron \
  && \
  chmod +x \
    /usr/local/bin/yacron

# Build yq
FROM debian-builder as yq-builder

RUN \
  curl https://github.com/mikefarah/yq/releases/download/3.4.0/yq_linux_amd64 --location --output /usr/local/bin/yq \
  && \
  chmod +x \
    /usr/local/bin/yq

# Build yt-dlp
FROM debian-builder as yt-dlp-builder

RUN \
  curl https://github.com/yt-dlp/yt-dlp/releases/download/2022.07.18/yt-dlp_linux --location --output /usr/local/bin/yt-dlp \
  && \
  chmod +x \
    /usr/local/bin/yt-dlp

# Main image
FROM ghcr.io/illallangi/debian:v0.0.8

# Install packages
RUN \
  apt-get update \
  && \
  apt-get install -y --no-install-recommends \
    apt-utils=1.8.2.3 \
    dnsutils=1:9.11.5.P4+dfsg-5.1+deb10u8 \
    fio=3.12-2 \
    flac=1.3.2-3+deb10u2 \
    git=1:2.20.1-2+deb10u3 \
    hardlink=0.3.2 \
    iperf3=3.6-2 \
    jq=1.5+dfsg-2+b1 \
    lame=3.100-2+b1 \
    librsvg2-bin=2.44.10-2.1+deb10u3 \
    libxml2-utils=2.9.4+dfsg1-7+deb10u4 \
    mdns-scan=0.5-5 \
    moreutils=0.62-1 \
    mtr=0.92-2 \
    nano=3.2-3 \
    netcat=1.10-41.1 \
    openssh-client=1:7.9p1-10+deb10u2 \
    procps=2:3.3.15-2 \
    python3-pip=18.1-5 \
    python3-setuptools=40.8.0-1 \
    rclone=1.45-3 \
    rename=1.10-1 \
    rsync=3.1.3-6 \
    sqlite3=3.27.2-3+deb10u2 \
    traceroute=1:2.1.0-2 \
    tree=1.8.0-1 \
  && \
  rm -rf /var/lib/apt/lists/*

COPY --from=healthz /healthz /usr/local/bin/healthz
COPY --from=cfssl-builder /usr/local/bin/cfssl /usr/local/bin/cfssl
COPY --from=cfssljson-builder /usr/local/bin/cfssljson /usr/local/bin/cfssljson
COPY --from=dumb-init-builder /usr/local/bin/dumb-init /usr/local/bin/dumb-init
COPY --from=gosu-builder /usr/local/bin/gosu /usr/local/bin/gosu
COPY --from=restic-builder /usr/local/bin/restic /usr/local/bin/restic
COPY --from=mktorrent-builder /usr/local/bin/mktorrent /usr/local/bin/mktorrent
COPY --from=whatmp3-builder /usr/local/bin/whatmp3 /usr/local/bin/whatmp3
COPY --from=yacron-builder /usr/local/bin/yacron /usr/local/bin/yacron
COPY --from=yq-builder /usr/local/bin/yq /usr/local/bin/yq
COPY --from=yt-dlp-builder /usr/local/bin/yt-dlp /usr/local/bin/yt-dlp

# Configure user
ENV PUID=0 \
    PGID=0

RUN groupadd -g 1000 -r    abc && \
    useradd  -u 1000 -r -g abc abc

# Configure entrypoint
COPY rootfs /
ENTRYPOINT ["/usr/local/bin/dumb-init", "-v", "--", "entrypoint.sh"]
CMD ["healthz"]
