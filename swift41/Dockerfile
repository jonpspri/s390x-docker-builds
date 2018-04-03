FROM ubuntu:xenial

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
         git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools \
	 libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev \
	 libncurses5-dev pkg-config libblocksruntime-dev libcurl4-openssl-dev \
	 autoconf libtool systemtap-sdt-dev tzdata rsync \
	 ca-certificates \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /swift-source

WORKDIR /swift-source

RUN git clone https://github.com/apple/swift.git
RUN ./swift/utils/update-checkout --clone --scheme swift-4.1-branch
RUN ./swift/utils/build-script -r

# VIM: let b:syntastic_dockerfile_hadolint_args = "--ignore DL3008"

