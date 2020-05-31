FROM docker.io/fedora:31

MAINTAINER Andrew Cole <andrew.cole@illallangi.com>

RUN yum -y install \
      bind-utils \
      coreutils \
      curl \
      findutils \
      fio \
      git \
      iproute \
      iperf3 \
      iputils \
      mtr \
      nano \
      openssh-clients \
      procps-ng \
      python2-pip \
      python3-pip \
      rsync \
      traceroute \
      wget \
      which; \
    yum -y update; \
    yum -y clean all

RUN wget \
      https://raw.githubusercontent.com/illallangi/hardlinkpy/master/hardlink.py \
      --output-file=/usr/local/bin/hardlink.py

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
