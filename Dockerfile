# Build hardlinkable, goose and cfssl
FROM docker.io/library/golang:1.15.8 AS golang

RUN apt-get -y update && apt-get install -y \
      musl-tools

RUN go get github.com/chadnetzer/hardlinkable
RUN go get github.com/spf13/cobra
RUN go get bitbucket.org/liamstask/goose/cmd/goose
RUN go get github.com/cloudflare/cfssl/cmd/...

ENV CC=/usr/bin/musl-gcc
RUN go build -ldflags "-linkmode external -extldflags -static" -o hardlinkable github.com/chadnetzer/hardlinkable/cmd/hardlinkable
RUN go build -ldflags "-linkmode external -extldflags -static" -o goose bitbucket.org/liamstask/goose/cmd/goose
RUN go build -ldflags "-linkmode external -extldflags -static" -o cfssl github.com/cloudflare/cfssl/cmd/cfssl
RUN go build -ldflags "-linkmode external -extldflags -static" -o cfssljson github.com/cloudflare/cfssl/cmd/cfssljson

# Build mktorrent
FROM docker.io/library/debian:buster-20210621 AS make

RUN apt-get -y update && apt-get install -y \
          curl \
          gcc \
          make

RUN mkdir -p /usr/local/src/mktorrent && \
    curl https://github.com/pobrn/mktorrent/archive/master.tar.gz --location | \
    tar -zxv --directory /usr/local/src/mktorrent --strip-components=1 && \
    make --directory /usr/local/src/mktorrent

# Main image
FROM docker.io/library/debian:buster-20210621
MAINTAINER Andrew Cole <andrew.cole@illallangi.com>

# Install packages
RUN apt-get -y update && apt-get install -y \
      apt-utils \
      curl \
      dnsutils \
      fio \
      flac \
      git \
      iperf3 \
      jq \
      lame \
      librsvg2-bin \
      libxml2-utils \
      mdns-scan \
      mtr \
      nano \
      netcat \
      openssh-client \
      procps \
      python3-pip \
      python3-setuptools \
      rename \
      rsync \
      traceroute \
      wget \
    && rm -rf /var/lib/apt/lists/*

# Install gosu
RUN curl https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64 --location --output /usr/local/bin/gosu \
    && chmod +x /usr/local/bin/gosu

# Install yq
RUN curl https://github.com/mikefarah/yq/releases/download/3.4.0/yq_linux_amd64 --location --output /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq

# Install confd
RUN curl https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 --location --output /usr/local/bin/confd \
    && chmod +x /usr/local/bin/confd

# Install dumb-init
RUN curl https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 --location --output /usr/local/bin/dumb-init \
    && chmod +x /usr/local/bin/dumb-init

# Install whatmp3
RUN curl https://github.com/RecursiveForest/whatmp3/archive/master.tar.gz --location | \
    tar -zxv --directory /usr/local/bin --strip-components=1 --transform 's/.py//g' whatmp3-master/whatmp3.py

# Copy hardlinkable, goose and cfssl
COPY --from=golang /go/hardlinkable /usr/local/bin/hardlinkable
COPY --from=golang /go/goose /usr/local/bin/goose
COPY --from=golang /go/cfssl /usr/local/bin/cfssl
COPY --from=golang /go/cfssljson /usr/local/bin/cfssljson

# Copy mktorrent
COPY --from=make /usr/local/src/mktorrent/mktorrent /usr/local/bin/mktorrent

# Configure user
ENV PUID=0 \
    PGID=0

RUN groupadd -g 1000 -r    abc && \
    useradd  -u 1000 -r -g abc abc

# Configure entrypoint
COPY bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*
ENTRYPOINT ["/usr/local/bin/dumb-init", "-v", "--", "entrypoint.sh"]

ARG VCS_REF
ARG VERSION
ARG BUILD_DATE
LABEL maintainer="Andrew Cole <andrew.cole@illallangi.com>" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.description="A collection of utilities installed onto a debian base image" \
      org.label-schema.name="Toolbx" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.url="http://github.com/illallangi/Toolbx" \
      org.label-schema.usage="https://github.com/illallangi/Toolbx/blob/master/README.md" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/illallangi/Toolbx" \
      org.label-schema.vendor="Illallangi Enterprises" \
      org.label-schema.version=$VERSION
