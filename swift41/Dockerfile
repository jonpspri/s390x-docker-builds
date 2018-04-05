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
RUN mkdir -p /swift-source 

WORKDIR /swift-source
RUN git clone https://github.com/apple/swift.git \
    && ./swift/utils/update-checkout --clone --scheme swift-${swiftversion}-branch

#  Cherry-pick some PRs needed for ppc64le compatibility (and otherwise harmless)
#
#  This probably needs to be set up for some other swift versions and architectures
RUN if [ "$(uname -m)-${swiftversion}" = "ppc64le-4.1" ]; then \
 git config --global user.name "OpenWhisk" \
 && git config --global user.email "dev@openwhisk.apache.org" \
 #
 #  For details, see https://github.com/apple/swift-corelibs-foundation/pull/1421
 && (cd swift-corelibs-foundation && git cherry-pick -m 1 0027637db85fd804b55ede3cfff26c913d2a90d0) \
 #
 #  For details, see https://github.com/apple/swift-package-manager/pull/1482
 && (cd swiftpm && git cherry-pick b78f787ff7c407d89fe41822fd6af7c23d1c4764) \
 #
 #  For details, see https://github.com/apple/swift-clang/pull/160
 #               and https://github.com/apple/swift-clang/pull/167
 #  The jonpspri repository has the commits needed to apply the changes to the 4.1 branch
 && (cd clang \
    && git remote add jonpspri https://github.com/jonpspri/swift-clang.git \
    && git fetch --quiet jonpspri \
    && git cherry-pick 9bfd531a07e6259f3d8d101ca26543e0ed064cbe \
    && git cherry-pick 8a46bf51827649642ee6c33ade6d1571554dae4c \
    ) \
 ;fi

RUN ./swift/utils/build-toolchain swift-${swiftversion}-linux-$(uname -m)
