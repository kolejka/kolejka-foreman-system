FROM ubuntu:jammy
MAINTAINER KOLEJKA <kolejka@matinf.uj.edu.pl>
ENTRYPOINT ["/bin/bash"]
WORKDIR /root

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_PRIORITY critical
ENV DEBIAN_FRONTEND noninteractive

RUN rm -f /etc/apt/sources.list.d/*
RUN echo "deb     http://archive.ubuntu.com/ubuntu/ jammy           main restricted universe multiverse" >  /etc/apt/sources.list && \
    echo "deb     http://archive.ubuntu.com/ubuntu/ jammy-updates   main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb     http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb     http://security.ubuntu.com/ubuntu jammy-security  main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get -f -y install \
        apt-transport-https \
        apt-utils \
        locales \
        software-properties-common \
    && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    true

RUN echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key 7EA0A9C3F273FCD8 && \
    echo "deb http://ppa.launchpad.net/kolejka/kolejka/ubuntu jammy main" > /etc/apt/sources.list.d/kolejka.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key EE527D561340007D && \
    echo "deb              http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64 /" > /etc/apt/sources.list.d/nvidia.list && \
    echo "deb              http://nvidia.github.io/libnvidia-container/ubuntu22.04/amd64 /" >> /etc/apt/sources.list.d/nvidia.list && \
    echo "deb              http://nvidia.github.io/nvidia-container-runtime/ubuntu22.04/amd64 /" >> /etc/apt/sources.list.d/nvidia.list && \
    echo "deb              http://nvidia.github.io/nvidia-docker/ubuntu22.04/amd64 /" >> /etc/apt/sources.list.d/nvidia.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key A4B469963BF863CC DDCAE044F796ECB0 && \
    apt-get update

RUN apt-get -y dist-upgrade

RUN mkdir -p /etc/modprobe.d && \
    echo "options nvidia \"NVreg_RestrictProfilingToAdminUsers=0\"" > /etc/modprobe.d/nvidia.conf && \
    true

RUN apt-get -f -y install \
        linux-headers-generic \
        linux-image-generic \
        linux-tools-generic \
        ubuntu-minimal \
        ubuntu-server \
    && \
    true

RUN apt-get -f -y install --no-install-recommends \
        nvidia-driver-515 \
    && \
    apt-get -f -y install \
        cuda-cudart-11-8 \
        cuda-command-line-tools-11-8 \
        nvidia-docker2 \
    && \
    true

RUN apt-get -f -y install \
        casper \
        docker-ce \ 
        ethtool \
        git \
        iptables \
        python3-kolejkaforeman \
        lshw \
        #lupin-casper \
        lvm2 \
        mdadm \
        nfs-client \
        python3-venv \
        screen \
        squashfs-tools \
        ssh \
        vim \
        vlan \
        xfsprogs \
    && \
    true

RUN apt-get -f -y remove \
        snapd \
        unattended-upgrades \
    && \
    true

RUN systemctl disable \
        apt-daily-upgrade.timer \
        apt-daily.timer \
        atd \
        cron \
    && \
    true

RUN sed -e "s|enabled=1|enabled=0|" -i /etc/default/apport

RUN apt-get -y autoremove

COPY rc.local /etc/rc.local
RUN chmod 755 /etc/rc.local

RUN mkdir /etc/kolejka
RUN chmod 0755 /etc/kolejka
COPY kolejka.conf /etc/kolejka/kolejka.conf
RUN chmod 0600 /etc/kolejka/kolejka.conf
