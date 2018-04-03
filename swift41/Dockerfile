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

RUN mkdir -p /swift-source

RUN git clone https://github.com/mackyle/blocksruntime \
	&& (cd blocksruntime \
		&& ./buildlib \
		&& prefix=/usr ./installlib)

WORKDIR /swift-source

RUN git clone https://github.com/apple/swift.git

ARG swiftversion=4.1

RUN ./swift/utils/update-checkout --clone --scheme swift-${swiftversion}-branch

RUN mkdir -p /swift-dest \
	&& ./swift/utils/build-script --preset=buildbot_linux \
		install_destdir=/swift-dest \
		installable_package=/swift-${swiftversion}-linux-$(uname -m).tar.gz

# VIM: let b:syntastic_dockerfile_hadolint_args = "--ignore DL3008"

