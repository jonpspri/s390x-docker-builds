m4_changequote({{,}})

# Dockerfile for swift actions, overrides and extends ActionRunner from actionProxy
# This Dockerfile is partially based on: https://github.com/swiftdocker/docker-swift/

FROM m4_ifdef({{S390X}},{{docker.xanophis.com/s390x/zesty-gold:latest}},{{ibmcom/ubuntu-swift}})

LABEL image_name=ubuntu-swift tags=3.1.1,3.1,latest

m4_ifdef({{S390X}},{{
# Upgrade and install basic Python dependencies
RUN DEBIAN_FRONTEND=noninteractive \
 && apt-get -y update \
 && apt-get -y install --fix-missing --no-install-recommends \
    wget libicu-dev zip libxml2 libbsd0 \

# Clean up
 && apt-get clean && rm -rf /var/lib/apt/lists \

# CLang was already installed as part of the `-gold' image.
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/clang++ 20 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang 20 \

#  TODO:  Address the mismatch in swift versions across the architectures
 && wget -qO- https://s3.amazonaws.com/s390x-openwhisk/swift-3.1.1-RELEASE.tar.gz | \
    tar zfx -
}},{{}})
