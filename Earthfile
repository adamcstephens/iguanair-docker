VERSION 0.6

build-all-platforms:
    BUILD --platform=linux/aarch64 --build-arg S6_ARCH=aarch64 +build-image
    BUILD --platform=linux/amd64 --build-arg S6_ARCH=x86_64 +build-image

base-image:
  ARG TARGETPLATFORM
  FROM --platform=$TARGETPLATFORM debian:bullseye-slim

  RUN apt-get update && apt-get --yes upgrade && apt-get --yes install ca-certificates

build-iguanair:
  ARG TARGETPLATFORM
  FROM --platform=$TARGETPLATFORM +base-image

  RUN apt-get --yes --no-install-recommends install \
    build-essential \
    cmake \
    debhelper \
    devscripts \
    git \
    liblirc-dev \
    liblircclient-dev \
    libsystemd-dev \
    libusb-1.0-0-dev \
    make \
    pkg-config \
    python-dev \
    python3-dev \
    swig \
    systemd \
    udev

  WORKDIR /build
  RUN git clone https://github.com/iguanaworks/iguanair
  WORKDIR /build/iguanair
  RUN git checkout c6284e5c07993db7adfa2729b7a3503224301572

  RUN ./mkChangelog -d stable --b 1 -o debian/changelog
  RUN sed -i 's/1.2.0-stable/1.2.0/' debian/changelog
  RUN sed -i '/dh-systemd/d' debian/control
  RUN sed -i '/systemctl daemon-reload/d' debian/iguanair.post*
  RUN dpkg-buildpackage -b

  WORKDIR /build

  SAVE ARTIFACT /build/iguanair_1.2.0_*.deb /build/ AS LOCAL output/
  SAVE ARTIFACT /build/libiguanair0_1.2.0_*.deb /build/ AS LOCAL output/
  SAVE ARTIFACT /build/lirc-drv-iguanair_1.2.0_*.deb /build/ AS LOCAL output/

build-image:
  ARG TARGETPLATFORM
  FROM --platform=$TARGETPLATFORM +base-image

  ARG S6_OVERLAY_VERSION=v3.1.2.1
  ARG S6_ARCH=x86_64
  ENV S6_OVERLAY_VERSION=$S6_OVERLAY_VERSION
  ENV S6_ARCH=$S6_ARCH

  RUN apt-get --yes install --no-install-recommends procps s6 wget xz-utils

  WORKDIR /tmp
  COPY --platform=$TARGETPLATFORM +build-iguanair/build /tmp
  RUN dpkg -i *.deb; apt-get --fix-broken --yes --no-install-recommends install && apt-get clean && rm -rf /var/cache/apt
  RUN rm -rf /tmp/*.deb /etc/lirc/lircd.conf.d/devinput.lircd.conf

  RUN wget https://github.com/just-containers/s6-overlay/releases/download/$S6_OVERLAY_VERSION/s6-overlay-noarch.tar.xz
  RUN wget https://github.com/just-containers/s6-overlay/releases/download/$S6_OVERLAY_VERSION/s6-overlay-$S6_ARCH.tar.xz
  RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
  RUN tar -C / -Jxpf /tmp/s6-overlay-$S6_ARCH.tar.xz
  WORKDIR /

  COPY services.d/ /etc/services.d/
  COPY cont-init.d/ /etc/cont-init.d/
  COPY lirc/ /etc/lirc/

  EXPOSE 8765

  ENTRYPOINT /init

  LABEL org.opencontainers.image.source=https://git.sr.ht/~adamcstephens/iguanair-docker
  SAVE IMAGE --push quay.io/adamcstephens/iguanair:latest
