FROM ubuntu:bionic

RUN apt-get update \
	 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		 git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools \
		 libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev \
		 libncurses5-dev pkg-config libcurl4-openssl-dev \
		 autoconf libtool systemtap-sdt-dev tzdata rsync \
		 ca-certificates \
	 && update-ca-certificates \
	 && rm -rf /var/lib/apt/lists/*


RUN git clone https://github.com/mackyle/blocksruntime \
	&& (cd blocksruntime \
		&& ./buildlib \
		&& prefix=/usr ./installlib)

ARG swiftversion=4.1
RUN mkdir -p /swift-source /swift-dest
WORKDIR /swift-source
RUN git clone https://github.com/apple/swift.git \
    && ./swift/utils/update-checkout --clone --scheme swift-${swiftversion}-branch

RUN mkdir -p /swift-dest \
	&& ./swift/utils/build-script -r \
	    --lldb -- \
	    --verbose-build=1 --install-swift \
	    --swift-install-components='autolink-driver;compiler;clang-builtin-headers;stdlib;sdk-overlay;license' \
	    --build-swift-static-stdlib=1 \
	    --install-prefix=/usr \
	    --install-destdir=/swift-dest \
	    --installable-package=/swift-${swiftversion}-linux-$(uname -m).tar.gz

# VIM: let b:syntastic_dockerfile_hadolint_args = "--ignore DL3008"

