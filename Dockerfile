# Debian Builder image
FROM docker.io/library/debian:buster-20220822 AS debian-builder

RUN \
  apt-get update \
  && \
  apt-get install -y --no-install-recommends \
    build-essential=12.6 \
    ca-certificates=20200601~deb10u2 \
    curl=7.64.0-4+deb10u3 \
    gcc=4:8.3.0-1 \
    make=4.2.1-1.2 \
  && \
  rm -rf /var/lib/apt/lists/*

# Golang Builder Image
FROM docker.io/library/golang:1.15.8 AS golang-builder

ENV CC=/usr/bin/musl-gcc
RUN \
  apt-get update \
  && \
  apt-get install -y --no-install-recommends \
    musl-tools=1.1.21-2 \
  && \
  rm -rf /var/lib/apt/lists/*

# Build caddy
FROM docker.io/library/caddy:2.5.2-builder AS caddy-builder

RUN xcaddy build \
    --with github.com/greenpau/caddy-security@v1.1.7 \
    --with github.com/hairyhenderson/caddy-teapot-module@v0.0.3-0

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

# Build confd
FROM debian-builder as confd-builder

RUN \
  curl https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 --location --output /usr/local/bin/confd \
  && \
  chmod +x \
    /usr/local/bin/confd

# Build dumb-init
FROM debian-builder as dumb-init-builder

RUN \
  curl "https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_$(uname -m)" --location --output /usr/local/bin/dumb-init \
  && \
  chmod +x \
    /usr/local/bin/dumb-init

# Build go-ipfs
FROM debian-builder as go-ipfs-builder

RUN \
  mkdir -p /usr/local/src/go-ipfs \
  && \
  curl https://dist.ipfs.io/go-ipfs/v0.10.0/go-ipfs_v0.10.0_linux-amd64.tar.gz --location --output /usr/local/src/go-ipfs.tar.gz \
  && \
  tar --gzip --extract --verbose --directory /usr/local/src/go-ipfs --strip-components=1 --file /usr/local/src/go-ipfs.tar.gz \
  && \
  cp /usr/local/src/go-ipfs/ipfs /usr/local/bin/ipfs

# Build goose
FROM golang-builder AS goose-builder

RUN \
  go get bitbucket.org/liamstask/goose/cmd/goose \
  && \
  go build -ldflags "-linkmode external -extldflags -static" -o /usr/local/bin/goose bitbucket.org/liamstask/goose/cmd/goose

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
  curl https://github.com/restic/restic/releases/download/v0.13.1/restic_0.13.1_linux_amd64.bz2 --location --output /usr/local/src/restic.bz2 \
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
FROM docker.io/library/debian:buster-20220822

# Install packages
RUN \
  apt-get update \
  && \
  apt-get install -y --no-install-recommends \
    apt-utils=1.8.2.3 \
    curl=7.64.0-4+deb10u3 \
    dnsutils=1:9.11.5.P4+dfsg-5.1+deb10u7 \
    fio=3.12-2 \
    flac=1.3.2-3+deb10u2 \
    git=1:2.20.1-2+deb10u3 \
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
    traceroute=1:2.1.0-2 \
    tree=1.8.0-1 \
  && \
  rm -rf /var/lib/apt/lists/*

COPY --from=caddy-builder /usr/bin/caddy /usr/local/bin/caddy
COPY --from=cfssl-builder /usr/local/bin/cfssl /usr/local/bin/cfssl
COPY --from=cfssljson-builder /usr/local/bin/cfssljson /usr/local/bin/cfssljson
COPY --from=confd-builder /usr/local/bin/confd /usr/local/bin/confd
COPY --from=dumb-init-builder /usr/local/bin/dumb-init /usr/local/bin/dumb-init
COPY --from=go-ipfs-builder /usr/local/bin/ipfs /usr/local/bin/ipfs
COPY --from=goose-builder /usr/local/bin/goose /usr/local/bin/goose
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
COPY root /
ENTRYPOINT ["/usr/local/bin/dumb-init", "-v", "--", "entrypoint.sh"]
