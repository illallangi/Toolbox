FROM golang:1.11

RUN apt-get -y update && apt-get install -y \
      musl-tools

RUN go get github.com/chadnetzer/hardlinkable && \
    go get github.com/spf13/cobra

ENV CC=/usr/bin/musl-gcc
RUN go build -ldflags "-linkmode external -extldflags -static" -o hardlinkable github.com/chadnetzer/hardlinkable/cmd/hardlinkable

FROM docker.io/library/debian:buster-20200607

MAINTAINER Andrew Cole <andrew.cole@illallangi.com>

# Install packages
RUN apt-get -y update && apt-get install -y \
      apt-utils \
      curl \
      dnsutils \
      fio \
      git \
      iperf3 \
      mtr \
      nano \
      openssh-client \
      procps \
      python-pip \
      python3-pip \
      rsync \
      traceroute \
      wget \
    && rm -rf /var/lib/apt/lists/*

# Configure alternatives
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 2 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.7 3 && \
    sed -i "1s/python$/python2/" /usr/bin/pip2 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip2 2 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 3

# Copy hardlinkable
COPY --from=0 /go/hardlinkable /usr/local/bin/hardlinkable

# Configure entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
