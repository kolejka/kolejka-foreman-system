FROM ubuntu:focal
MAINTAINER KOLEJKA <kolejka@matinf.uj.edu.pl>
ENTRYPOINT ["/bin/bash"]
WORKDIR /root

ENV DEBIAN_PRIORITY critical
ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN rm -f /etc/apt/sources.list.d/*
RUN echo "deb     http://archive.ubuntu.com/ubuntu/ focal           main restricted universe multiverse" >  /etc/apt/sources.list && \
    echo "deb     http://archive.ubuntu.com/ubuntu/ focal-updates   main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb     http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb     http://security.ubuntu.com/ubuntu focal-security  main restricted universe multiverse" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -f -y install \
        apt-transport-https \
        apt-utils \
        locales \
        software-properties-common && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key 7EA0A9C3F273FCD8

RUN echo "deb http://ppa.launchpad.net/kolejka/kolejka/ubuntu focal main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key EE527D561340007D

RUN echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /" >> /etc/apt/sources.list && \
    echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64 /" >> /etc/apt/sources.list && \
    echo "deb http://nvidia.github.io/libnvidia-container/ubuntu20.04/amd64 /" >> /etc/apt/sources.list && \
    echo "deb http://nvidia.github.io/nvidia-container-runtime/ubuntu20.04/amd64 /" >> /etc/apt/sources.list && \
    echo "deb http://nvidia.github.io/nvidia-docker/ubuntu20.04/amd64 /" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key F60F4B3D7FA2AF80 C45B1676A04EA552

RUN apt-get update && \
    apt-get -y dist-upgrade
RUN apt-get -f -y install \
        ubuntu-minimal \
        ubuntu-server
RUN apt-get -f -y install \
        linux-headers-generic \
        linux-image-generic \
        linux-tools-generic

RUN apt-get -f -y install --no-install-recommends \
        nvidia-driver-460 && \
    apt-get -f -y install \
        cuda-cudart-11.2 \
        cuda-command-line-tools-11.2 \
        nvidia-docker2

RUN apt-get -f -y install \
        casper \
        docker-ce \ 
        #docker.io \
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
