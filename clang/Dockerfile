FROM ubuntu:bionic

COPY ppc64le-clang.patch /

RUN sed -i -e 's/^# deb-src/deb-src/' /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
         devscripts=2.17.* \
         fakeroot=1.22-* \
 && mkdir build \
 && (cd build && apt-get source llvm-toolchain-6.0) \
 && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends \
         build-dep llvm-toolchain-6.0 \
 && rm -rf /var/lib/apt/lists/*

RUN (cd /build/llvm-toolchain-6.0-*/clang && patch -p1 </ppc64le-clang.patch)

RUN (cd /build/llvm-toolchain-6.0-* && debuild -us -uc -b)

