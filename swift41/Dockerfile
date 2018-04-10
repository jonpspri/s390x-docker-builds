FROM ubuntu:bionic

RUN mkdir /ppc64le
COPY ppc64le/clang-6.0_6.0-1ubuntu2_ppc64el.deb /ppc64le
COPY ppc64le/libllvm6.0_6.0-1ubuntu2_ppc64el.deb /ppc64le
COPY ppc64le/libclang-common-6.0-dev_6.0-1ubuntu2_ppc64el.deb /ppc64le
COPY ppc64le/libclang1-6.0_6.0-1ubuntu2_ppc64el.deb /ppc64le

RUN set -eu; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	git cmake ninja-build python uuid-dev libicu-dev icu-devtools \
	    libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev \
	    libncurses5-dev pkg-config libcurl4-openssl-dev \
	    autoconf libtool systemtap-sdt-dev tzdata rsync \
	    ca-certificates \
	    libstdc++-7-dev libobjc-7-dev \
	    ; \
    if [ "$(uname -m)" = "ppc64le" ]; then \
	dpkg -i /ppc64le/*.deb ; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -f ; \
	for i in clang++ clang clang-cpp; do \
	  ln -v -s /usr/bin/${i}-6.0 /usr/bin/${i} ; \
	done ; \
    else \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	    clang \
	    ; \
    fi ;\
    update-ca-certificates ;  \
    rm -rf /ppc64le /clang-6.0_6.0-1ubuntu2_ppc64el.deb /var/lib/apt/lists/*

RUN git clone https://github.com/mackyle/blocksruntime \
	&& (cd blocksruntime \
		&& ./buildlib \
		&& prefix=/usr ./installlib)

ARG swiftversion=4.1
RUN mkdir -p /swift-source \
   && (cd /swift-source \
      && git clone https://github.com/apple/swift.git \
      && ./swift/utils/update-checkout --clone --scheme "swift-${swiftversion}-branch" \
   )

#  Cherry-pick some PRs needed for ppc64le compatibility (and otherwise harmless)
#
#  This probably needs to be set up for some other swift versions and architectures
RUN if [ "$(uname -m)-${swiftversion}" = "ppc64le-4.1" ]; then \
	git config --global user.name "OpenWhisk" \
	&& git config --global user.email "dev@openwhisk.apache.org" \
	#
	#  For details, see https://github.com/apple/swift-corelibs-foundation/pull/1421
	&& (cd /swift-source/swift-corelibs-foundation \
	    && git cherry-pick -m 1 0027637db85fd804b55ede3cfff26c913d2a90d0) \
	#
	#  For details, see https://github.com/apple/swift-package-manager/pull/1482
	&& (cd /swift-source/swiftpm \
	    && git cherry-pick b78f787ff7c407d89fe41822fd6af7c23d1c4764) \
	#
	#  For details, see https://github.com/apple/swift-clang/pull/160
	#               and https://github.com/apple/swift-clang/pull/167
	#  The jonpspri repository has the commits needed to apply the changes to the 4.1 branch
	#  TODO: Make the commits into a patch instead
        && (cd /swift-source/clang \
	    && git remote add jonpspri https://github.com/jonpspri/swift-clang.git \
	    && git fetch --quiet jonpspri \
	    && git cherry-pick 9bfd531a07e6259f3d8d101ca26543e0ed064cbe \
	    && git cherry-pick 8a46bf51827649642ee6c33ade6d1571554dae4c \
	) \
  ;fi

RUN mkdir /swift-build \
    && /swift-source/swift/utils/build-script \
	#--preset-file /build-presets.ini \
	--preset=buildbot_linux_1604 \
        install_destdir=/swift-build \
	"installable_package=/swift-${swiftversion}-$(uname -m)" \
    || exit 0

#  VIM:  let b:syntastic_dockerfile_hadolint_args="--ignore SC2154 --ignore DL3008"
