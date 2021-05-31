# syntax=docker/dockerfile:1
FROM debian:bullseye-slim AS base

ARG S6_OVERLAY_VERSION=v2.2.0.3
ENV S6_OVERLAY_VERSION=$S6_OVERLAY_VERSION

RUN apt-get update

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
COPY --from=build /build/iguanair_1.2.0_amd64.deb /build/libiguanair0_1.2.0_amd64.deb /build/lirc-drv-iguanair_1.2.0_amd64.deb ./
RUN dpkg -i *.deb; apt-get --fix-broken --yes --no-install-recommends install && apt-get clean && rm -rf /var/cache/apt
RUN rm -rf /tmp/*.deb /etc/lirc/lircd.conf.d/devinput.lircd.conf

RUN curl -L https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar xz -C /

WORKDIR /

COPY services.d/ /etc/services.d/
COPY lirc/ /etc/lirc/

ENTRYPOINT /init
