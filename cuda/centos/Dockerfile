ARG CUDA_VERSION=12.4.0
ARG BASE_VERSION=7

FROM nvidia/cuda:${CUDA_VERSION}-devel-centos${BASE_VERSION}
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# SOURCE
RUN sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo \
      && sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo \
      && sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
RUN yum install -y centos-release-scl \
      && sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo \
      && sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo \
      && sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo \
      && yum update -y
RUN yum install -y epel-release --enablerepo=extras \
      && yum install -y https://packages.endpointdev.com/rhel/7/os/$(uname -m)/endpoint-repo.$(uname -m).rpm \
      && yum update -y

# TOOLS
RUN yum install -y \
      ca-certificates binutils \
      unzip xz \
      git git-lfs \
      curl \
      vim jq bc

# GCC
RUN yum install -y \
      devtoolset-9 devtoolset-9-libatomic-devel devtoolset-9-elfutils-libelf-devel; \
    ln -vsf /opt/rh/devtoolset-9/root/bin/* /usr/bin/; \
    rm -rf /usr/lib/gcc \
      && ln -vsf /opt/rh/devtoolset-9/root/usr/lib/* /usr/lib/; \
    echo "/usr/lib/gcc/$(uname -m)-redhat-linux/9" >> /etc/ld.so.conf; \
    echo "/opt/rh/devtoolset-9/root/usr/lib64" >> /etc/ld.so.conf; \
    echo "/opt/rh/devtoolset-9/root/usr/lib64/dyninst" >> /etc/ld.so.conf; \
    ldconfig -v

# MAKE & CMAKE & SCCACHE
ENV CMAKE_VERSION=3.22.1 \
    SCCACHE_VERSION=0.10.0
RUN yum install -y \
      pkgconfig make; \
    curl -sL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-$(uname -m).tar.gz" | tar -zx -C /usr --strip-components 1; \
    curl -sL "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-$(uname -m)-unknown-linux-musl.tar.gz" | tar -zx -C /usr/bin --strip-components 1

# OPENSSL
ENV OPENSSL_VESION=3.4.0
RUN yum install -y \
      perl perl-IPC-Cmd perl-Test-Simple perl-CPAN; \
    curl -sL "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VESION}/openssl-${OPENSSL_VESION}.tar.gz" | tar -zx -C /tmp \
      && loc=$(pwd) && cd /tmp/openssl-${OPENSSL_VESION} \
      && ./config --prefix=/usr --openssldir=/etc/ssl shared enable-ssl3 enable-ssl3-method enable-mdc2 enable-md2 no-tests \
      && make -j $(nproc) build_sw && make -j $(nproc) install_sw \
      && cd ${loc} && rm -rf /tmp/openssl-${OPENSSL_VESION} \
      && echo "/usr/lib" >> /etc/ld.so.conf \
      && echo "/usr/lib64" >> /etc/ld.so.conf \
      && ldconfig -v | grep libssl

# OPENBLAS
ENV OPENBLAS_VERSION=0.3.29
RUN yum install -y \
      perl yasm; \
    curl -sL "https://github.com/OpenMathLib/OpenBLAS/releases/download/v${OPENBLAS_VERSION}/OpenBLAS-${OPENBLAS_VERSION}.tar.gz" | tar -zx -C /tmp \
      && loc=$(pwd) && cd /tmp/OpenBLAS-${OPENBLAS_VERSION} \
      && make -j $(nproc) PREFIX=/usr USE_OPENMP=0 NUM_THREADS=32 TARGET=$([ "$(uname -m)" = "x86_64" ] && printf "GENERIC" || printf "ARMV8") libs shared install \
      && cd ${loc} && rm -rf /tmp/OpenBLAS-${OPENBLAS_VERSION} \
      && echo "/usr/lib" >> /etc/ld.so.conf \
      && echo "/usr/lib64" >> /etc/ld.so.conf \
      && ldconfig -v | grep libopenblas

# # FFMPEG
# ENV FFMPEG_VESION=n7.1
# RUN yum install -y \
#       perl yasm; \
#     git config --global advice.detachedHead false \
#       && git clone --depth 1 --branch ${FFMPEG_VESION} https://github.com/FFmpeg/FFmpeg.git /tmp/FFmpeg-${FFMPEG_VESION} \
#       && loc=$(pwd) && cd /tmp/FFmpeg-${FFMPEG_VESION} \
#       && ./configure --prefix=/usr --enable-gpl --enable-shared --disable-programs --disable-doc --disable-debug --disable-stripping \
#       && make -j $(nproc) all && make -j $(nproc) install \
#       && cd ${loc} && rm -rf /tmp/FFmpeg-${FFMPEG_VESION} \
#       && echo "/usr/lib" >> /etc/ld.so.conf \
#       && echo "/usr/lib64" >> /etc/ld.so.conf \
#       && ldconfig -v | grep libav
