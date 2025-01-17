ARG ONEAPI_VERSION=2025.0.0-0
ARG BASE_VERSION=22.04

FROM intel/oneapi-basekit:${ONEAPI_VERSION}-devel-ubuntu${BASE_VERSION}

# SOURCE
RUN apt-get update -y \
      && apt-get install -y software-properties-common \
      && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
      && apt-get update -y

# MAKE & CCACHE & CURL & GIT
RUN apt-get install -y make ccache curl git \
      && make --version \
      && ccache --version \
      && curl --version \
      && git --version

# CMAKE
RUN apt-get install -y cmake

# GCC
RUN apt-get install -y build-essential

# OPENSSL
ENV OPENSSL_VESION=3.4.0
RUN apt-get remove -y libssl-dev perl-openssl-defaults \
      && apt-get install -y perl \
      && curl -sL "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VESION}/openssl-${OPENSSL_VESION}.tar.gz" | tar -zx -C /tmp \
      && loc=$(pwd) && cd /tmp/openssl-${OPENSSL_VESION} \
      && ./config --prefix=/usr --openssldir=/etc/ssl shared enable-ssl3 enable-ssl3-method enable-mdc2 enable-md2 no-tests \
      && make -j $(nproc) build_sw && make -j $(nproc) install_sw \
      && cd ${loc} && rm -rf /tmp/openssl-${OPENSSL_VESION} \
      && echo "/usr/lib" >> /etc/ld.so.conf \
      && echo "/usr/lib64" >> /etc/ld.so.conf \
      && ldconfig -v | grep libssl

# FFMPEG
ENV FFMPEG_VESION=n7.1
RUN apt-get install -y perl yasm \
      && git config --global advice.detachedHead false \
      && git clone --depth 1 --branch ${FFMPEG_VESION} https://github.com/FFmpeg/FFmpeg.git /tmp/FFmpeg-${FFMPEG_VESION} \
      && loc=$(pwd) && cd /tmp/FFmpeg-${FFMPEG_VESION} \
      && ./configure --prefix=/usr --enable-gpl --enable-shared --disable-programs --disable-doc --disable-debug --disable-stripping \
      && make -j $(nproc) all && make -j $(nproc) install \
      && cd ${loc} && rm -rf /tmp/FFmpeg-${FFMPEG_VESION} \
      && echo "/usr/lib" >> /etc/ld.so.conf \
      && echo "/usr/lib64" >> /etc/ld.so.conf \
      && ldconfig -v | grep libav

# OPENBLAS
ENV OPENBLAS_VERSION=0.3.29
RUN ARCH=$(uname -m) \
      && curl -sL "https://github.com/OpenMathLib/OpenBLAS/releases/download/v${OPENBLAS_VERSION}/OpenBLAS-${OPENBLAS_VERSION}.tar.gz" | tar -zx -C /tmp \
      && loc=$(pwd) && cd /tmp/OpenBLAS-${OPENBLAS_VERSION} \
      && make -j $(nproc) PREFIX=/usr USE_OPENMP=0 NUM_THREADS=32 TARGET=$([ "${ARCH}" = "x86_64" ] && printf "GENERIC" || printf "ARMV8") libs shared install \
      && cd ${loc} && rm -rf /tmp/OpenBLAS-${OPENBLAS_VERSION} \
      && echo "/usr/lib" >> /etc/ld.so.conf \
      && echo "/usr/lib64" >> /etc/ld.so.conf \
      && ldconfig -v | grep libopenblas
