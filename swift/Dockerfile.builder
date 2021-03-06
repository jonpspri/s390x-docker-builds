#LABEL xenial-gold

#
#  Swift's size requires Docker to be configured to provide at least 30GB of
#  storage for the base image.  I may change the process to mount a host
#  directory at some point, but for now having docker manage storage makes
#  the most sense.
#
#  I run this container on an underlying instance with 16GB.  At lower memory
#  levels, it's necessary to single-thread the build ('-j1' option) to prevent
#  memory blow-outs.
#

FROM s390x/ubuntu:xenial

#  Debian distros for s390 x do not include the 'gold' linker by default, so
#  instead we must build and install it from scratch.
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
        autoconf automake libtool git cmake ninja-build python \
        python-dev python3-dev uuid-dev libicu-dev \
        icu-devtools libbsd-dev libedit-dev libxml2-dev \
        libsqlite3-dev swig libpython-dev libncurses5-dev \
        pkg-config libcurl4-openssl-dev wget \
	ca-certificates \
	g++ bison rsync \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && :

RUN mkdir /binutils && cd /binutils \
 && wget -qO- http://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.gz \
        | tar zfx - --strip-components=1 \
 && ./configure --enable-gold \
 && make && make install \
 && cd / && rm -rf /binutils \
 && :

#  The Core Foundation library expects these libraries to be installed on the
#  system.  Although the files are included in the downloaded library, this
#  may be the path of least resistance to make them available to the platform.
RUN mkdir -p /blocksruntime && cd /blocksruntime \
 && wget -qO- https://api.github.com/repos/mackyle/blocksruntime/tarball/master \
      | tar zfx - --strip-components=1 \
 && ./buildlib && ./installlib \
 && cd / && rm -rf /blocksruntime \
 && :

#  These are directions on building Swift 3.0.1 from
#  https://github.com/linux-on-ibm-z/docs/wiki/Building-Swift

ARG BUILD_BRANCH=3.0
RUN : \
 && git clone https://github.com/linux-on-ibm-z/llvm.git \
 && cd llvm \
 && git checkout "llvm-for-swift-${BUILD_BRANCH}" \
 && cd tools \
 && git clone https://github.com/linux-on-ibm-z/clang.git \
 && cd clang \
 && git checkout "clang-for-swift-${BUILD_BRANCH}" \
 && cd ../../projects \
 && git clone https://github.com/linux-on-ibm-z/compiler-rt.git \
 && cd compiler-rt \
 && git checkout compiler-rt-for-swift-3.0 && cd .. \
 && mkdir /llvm-build \
 && cd /llvm-build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/llvm \
      -DPYTHON_INCLUDE_DIR=/usr/include/python2.7 \
      -DPYTHON_LIBRARY=/usr/lib/python2.7/config-s390x-linux-gnu/libpython2.7.so \
      -DCURSES_INCLUDE_PATH=/usr/include \
      -DCURSES_LIBRARY=/usr/lib/s390x-linux-gnu/libncurses.so \
      -DCURSES_PANEL_LIBRARY=/usr/lib/s390x-linux-gnu/libpanel.so \
      ../llvm \
 && make -j2 install \
 && rm -rf /llvm /llvm-build

ENV PATH=/opt/llvm/bin:$PATH

ARG RELEASE=swift-3.0.2-RELEASE
RUN : \
 && mkdir swift3 && cd swift3 \
 && git clone https://github.com/apple/swift.git \
 && cd swift \
 && ./utils/update-checkout --clone --tag "$RELEASE" \
 && rm ./utils/swift_build_support/__init__.pyc \
 && cd ../swift-corelibs-libdispatch \
 && git submodule init \
 && git submodule update --recursive \
 && if [ "$RELEASE" = "swift-3.0.1-RELEASE" ]; then : \
       && cd /swift3/swiftpm \
       && git config user.email "dummy@test.org" \
       && git config user.name "Dummy Name" \
       && git cherry-pick ad3228bea5c4919c476e17ae6beca079f1a7845f \
  ; fi \
 && /swift3/swift/utils/build-script -j 2 -R -- \
    	--foundation --xctest --llbuild --swiftpm --libdispatch -- \
    	--install-swift --install-foundation --install-xctest --install-llbuild \
      --install-swiftpm --install-libdispatch \
    	--swift-install-components='autolink-driver;compiler;clang-builtin-headers;stdlib;sdk-overlay;license' \
    	--build-swift-static-stdlib=1 \
    	--install-prefix=/usr \
    	--install-destdir=/swift3-build
 && cd /swift3-build \
 && tar zfcv /${RELEASE}.tar.gz usr \
 && find . -name '*.o' -print0 | xargs rm -0 \
 && :
