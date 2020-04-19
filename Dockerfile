FROM ubuntu:bionic
MAINTAINER KOLEJKA <kolejka@matinf.uj.edu.pl>
ENTRYPOINT ["/bin/bash"]
WORKDIR /root

ENV DEBIAN_PRIORITY critical
ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN rm -f /etc/apt/sources.list.d/*
RUN echo "deb     http://archive.ubuntu.com/ubuntu/ bionic           main restricted universe multiverse" >  /etc/apt/sources.list && \
    echo "deb     http://archive.ubuntu.com/ubuntu/ bionic-updates   main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb     http://archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb     http://security.ubuntu.com/ubuntu bionic-security  main restricted universe multiverse" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -f -y install \
        apt-transport-https \
        apt-utils \
        locales \
        software-properties-common && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key 7EA0A9C3F273FCD8
RUN echo "deb http://ppa.launchpad.net/kolejka/kolejka/ubuntu bionic main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key EE527D561340007D
RUN apt-get update && \
    apt-get -y dist-upgrade
RUN apt-get -f -y install \
        ubuntu-minimal \
        ubuntu-server
RUN apt-get -f -y install \
        linux-headers-generic \
        linux-image-generic \
        linux-tools-generic

RUN apt-get -f -y install \
        btrfs-tools \
        casper \
        docker-ce=5:19.03.6~3-0~ubuntu-bionic \
        ethtool \
        git \
        iptables \
        python3-kolejkaforeman \
        lshw \
        lupin-casper \
        lvm2 \
        mdadm \
        nfs-client \
        python3-venv \
        screen \
        squashfs-tools \
        ssh \
        vim \
        vlan \
        xfsprogs

RUN apt-get -f -y remove \
        snapd \
        unattended-upgrades

RUN systemctl disable \
        apt-daily-upgrade.timer \
        apt-daily.timer \
        atd \
        cron

RUN sed -e "s|enabled=1|enabled=0|" -i /etc/default/apport

RUN apt-get -y autoremove

COPY rc.local /etc/rc.local
RUN chmod 755 /etc/rc.local

RUN mkdir /etc/kolejka
RUN chmod 0755 /etc/kolejka
COPY kolejka.conf /etc/kolejka/kolejka.conf
RUN chmod 0600 /etc/kolejka/kolejka.conf
