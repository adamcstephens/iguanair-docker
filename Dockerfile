# syntax=docker/dockerfile:1
FROM debian:bullseye-slim AS base

ARG S6_OVERLAY_VERSION=v2.11.1.0
ARG S6_ARCH=amd64
ENV S6_OVERLAY_VERSION=$S6_OVERLAY_VERSION
ENV S6_ARCH=$S6_ARCH

ARG DEB_ARCH=amd64
ENV DEB_ARCH=$DEB_ARCH

RUN apt-get update && apt-get --yes upgrade

FROM base AS build

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

FROM base AS final

RUN apt-get --yes install --no-install-recommends ca-certificates curl procps

WORKDIR /tmp
COPY --from=build /build/iguanair_1.2.0_${DEB_ARCH}.deb /build/libiguanair0_1.2.0_${DEB_ARCH}.deb /build/lirc-drv-iguanair_1.2.0_${DEB_ARCH}.deb ./
RUN dpkg -i *.deb; apt-get --fix-broken --yes --no-install-recommends install && apt-get clean && rm -rf /var/cache/apt
RUN rm -rf /tmp/*.deb /etc/lirc/lircd.conf.d/devinput.lircd.conf

RUN curl -L https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz | tar xz -C /

WORKDIR /

COPY services.d/ /etc/services.d/
COPY cont-init.d/ /etc/cont-init.d/
COPY lirc/ /etc/lirc/

EXPOSE 8765

ENTRYPOINT /init
