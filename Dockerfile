FROM docker.io/fedora:31

MAINTAINER Andrew Cole <andrew.cole@illallangi.com>

RUN yum -y install coreutils findutils which openssh-clients rsync; \
    yum -y update; \
    yum -y clean all

COPY toolbox-entrypoint.sh /toolbox-entrypoint.sh

RUN chmod +x /toolbox-entrypoint.sh

ENTRYPOINT ["/toolbox-entrypoint.sh"]