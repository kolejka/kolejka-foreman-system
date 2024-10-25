ARG UBUNTU_NAME=noble
FROM ubuntu:${UBUNTU_NAME}
ARG UBUNTU_NAME
ARG UBUNTU_RELEASE=24.04
ARG UBUNTU_RELEASE_SIMPLE=2404
ARG NVIDIA_DRIVER_VERSION=560
ARG CUDA_VERSION=12-6
ARG KERNEL_VERSION=generic-hwe-24.04
LABEL org.opencontainers.authors="KOLEJKA <kolejka@matinf.uj.edu.pl>"
ENTRYPOINT ["/bin/bash"]
WORKDIR /root

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_PRIORITY critical
ENV DEBIAN_FRONTEND noninteractive

RUN rm -f /etc/apt/sources.list.d/*
RUN echo "deb     http://archive.ubuntu.com/ubuntu/ ${UBUNTU_NAME}           main restricted universe multiverse" >  /etc/apt/sources.list && \
    echo "deb     http://archive.ubuntu.com/ubuntu/ ${UBUNTU_NAME}-updates   main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb     http://archive.ubuntu.com/ubuntu/ ${UBUNTU_NAME}-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb     http://security.ubuntu.com/ubuntu ${UBUNTU_NAME}-security  main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get -f -y install \
        apt-transport-https \
        apt-utils \
        curl \
        locales \
        software-properties-common \
    && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    true

RUN curl --silent --show-error --fail --location --output /tmp/docker.gpg "https://download.docker.com/linux/ubuntu/gpg" && \
    cat /tmp/docker.gpg |gpg --dearmor > /etc/apt/trusted.gpg.d/docker.gpg && \
    rm -f /tmp/docker.gpg && \
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu noble stable" > /etc/apt/sources.list.d/docker.list && \
    curl --silent --show-error --fail --location --output /tmp/cuda.deb "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb" && \
    dpkg -i /tmp/cuda.deb && \
    rm -f /tmp/cuda.deb && \
    curl --silent --show-error --fail --location --output /tmp/nvidia.gpg "https://nvidia.github.io/nvidia-docker/gpgkey" && \
    cat /tmp/nvidia.gpg |gpg --dearmor > /etc/apt/trusted.gpg.d/nvidia.gpg && \
    rm -f /tmp/nvidia.gpg && \
    echo "deb [arch=amd64] http://nvidia.github.io/libnvidia-container/stable/deb/amd64 /" >> /etc/apt/sources.list.d/nvidia.list && \
    apt-add-repository --no-update ppa:kolejka/kolejka && \
    apt-get update && \
    apt-get -y dist-upgrade

RUN apt-get -f -y install \
        linux-headers-${KERNEL_VERSION} \
        linux-image-${KERNEL_VERSION} \
        linux-tools-${KERNEL_VERSION} \
        ubuntu-minimal \
        ubuntu-server \
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
        lvm2 \
        mdadm \
        nfs-client \
        python3-venv \
        rsync \
        screen \
        squashfs-tools \
        ssh \
        vim \
        vlan \
        xfsprogs \
    && \
    true

RUN apt-get -f -y install --no-install-recommends \
        nvidia-driver-${NVIDIA_DRIVER_VERSION} \
    && \
    apt-get -f -y install \
        cuda-cudart-${CUDA_VERSION} \
        cuda-command-line-tools-${CUDA_VERSION} \
        nvidia-container-toolkit \
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
    && \
    true

RUN sed -e "s|enabled=1|enabled=0|" -i /etc/default/apport

RUN mkdir -p /etc/modprobe.d && \
    echo "options nvidia \"NVreg_RestrictProfilingToAdminUsers=0\"" > /etc/modprobe.d/nvidia.conf && \
    true

RUN apt-get -y autoremove

COPY rc.local /etc/rc.local
RUN chmod 755 /etc/rc.local

RUN mkdir /etc/kolejka
RUN chmod 0755 /etc/kolejka
COPY kolejka.conf /etc/kolejka/kolejka.conf
RUN chmod 0600 /etc/kolejka/kolejka.conf
