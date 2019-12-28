FROM docker.io/fedora:31

MAINTAINER Andrew Cole <andrew.cole@illallangi.com>

RUN yum -y install \
      bind-utils \
      coreutils \
      curl \
      findutils \
      iproute \
      iputils \
      mtr \
      nano \
      openssh-clients \
      procps-ng \
      rsync \
      traceroute \
      wget \
      which; \
    yum -y update; \
    yum -y clean all

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
