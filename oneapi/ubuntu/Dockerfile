ARG ONEAPI_VERSION=2025.0.0-0
ARG BASE_VERSION=22.04

FROM intel/oneapi-basekit:${ONEAPI_VERSION}-devel-ubuntu${BASE_VERSION}
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# SOURCE
RUN apt-get update -y && apt-get install -y software-properties-common apt-transport-https \
      && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
      && apt-get update -y

# TOOLS
RUN apt-get install -y --no-install-recommends \
      ca-certificates build-essential binutils \
      unzip xz-utils \
      git git-lfs \
      curl \
      vim jq bc

# GCC
RUN <<EOF
    source /etc/os-release
    if (( $(echo "${VERSION_ID} < 21.04" | bc -l) )); then
      apt-get install -y --no-install-recommends \
        gcc-11 g++-11 gfortran-11 gfortran
      if [ -f /etc/alternatives/gcov-dump ]; then update-alternatives --remove-all gcov-dump; fi; update-alternatives --install /usr/bin/gcov-dump gcov-dump /usr/bin/gcov-dump-11 10
      if [ -f /etc/alternatives/lto-dump ]; then update-alternatives --remove-all lto-dump; fi; update-alternatives --install /usr/bin/lto-dump lto-dump /usr/bin/lto-dump-11 10
      if [ -f /etc/alternatives/gcov ]; then update-alternatives --remove-all gcov; fi; update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-11 10
      if [ -f /etc/alternatives/gcc ]; then update-alternatives --remove-all gcc; fi; update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 10
      if [ -f /etc/alternatives/gcc-nm ]; then update-alternatives --remove-all gcc-nm; fi; update-alternatives --install /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-11 10
      if [ -f /etc/alternatives/cpp ]; then update-alternatives --remove-all cpp; fi; update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-11 10
      if [ -f /etc/alternatives/g++ ]; then update-alternatives --remove-all g++; fi; update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 10
      if [ -f /etc/alternatives/gcc-ar ]; then update-alternatives --remove-all gcc-ar; fi; update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-11 10
      if [ -f /etc/alternatives/gcov-tool ]; then update-alternatives --remove-all gcov-tool; fi; update-alternatives --install /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-11 10
      if [ -f /etc/alternatives/gcc-ranlib ]; then update-alternatives --remove-all gcc-ranlib; fi; update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-11 10
      if [ -f /etc/alternatives/gfortran ]; then update-alternatives --remove-all gfortran; fi; update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-11 10
    fi
    echo "/usr/lib/gcc/$(uname -m)-linux-gnu/11" >> /etc/ld.so.conf
    ldconfig -v
EOF

# MAKE & CMAKE & SCCACHE
ENV CMAKE_VERSION=3.22.1 \
    SCCACHE_VERSION=0.10.0
RUN apt-get install -y --no-install-recommends \
      pkg-config make; \
    curl -sL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-$(uname -m).tar.gz" | tar -zx -C /usr --strip-components 1; \
    curl -sL "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-$(uname -m)-unknown-linux-musl.tar.gz" | tar -zx -C /usr/bin --strip-components 1

# OPENSSL
ENV OPENSSL_VESION=3.4.0
RUN apt-get remove -y \
      libssl-dev perl-openssl-defaults; \
    apt-get install -y --no-install-recommends \
      perl; \
    curl -sL "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VESION}/openssl-${OPENSSL_VESION}.tar.gz" | tar -zx -C /tmp \
      && loc=$(pwd) && cd /tmp/openssl-${OPENSSL_VESION} \
      && ./config --prefix=/usr --openssldir=/etc/ssl shared enable-ssl3 enable-ssl3-method enable-mdc2 enable-md2 no-tests \
      && make -j $(nproc) build_sw && make -j $(nproc) install_sw \
      && cd ${loc} && rm -rf /tmp/openssl-${OPENSSL_VESION} \
      && echo "/usr/lib" >> /etc/ld.so.conf \
      && echo "/usr/lib64" >> /etc/ld.so.conf \
      && ln -s /usr/lib64/libssl.so /usr/lib/libssl.so \
      && ln -s /usr/lib64/libssl.a /usr/lib/libssl.a \
      && ln -s /usr/lib64/libcrypto.so /usr/lib/libcrypto.so \
      && ln -s /usr/lib64/libcrypto.a /usr/lib/libcrypto.a; \
    ldconfig -v | grep libssl

# OPENBLAS
ENV OPENBLAS_VERSION=0.3.29
RUN apt-get install -y --no-install-recommends \
      perl yasm; \
    curl -sL "https://github.com/OpenMathLib/OpenBLAS/releases/download/v${OPENBLAS_VERSION}/OpenBLAS-${OPENBLAS_VERSION}.tar.gz" | tar -zx -C /tmp \
      && loc=$(pwd) && cd /tmp/OpenBLAS-${OPENBLAS_VERSION} \
      && make -j $(nproc) PREFIX=/usr USE_OPENMP=0 NUM_THREADS=32 TARGET=$([ "$(uname -m)" = "x86_64" ] && printf "GENERIC" || printf "ARMV8") libs shared install \
      && cd ${loc} && rm -rf /tmp/OpenBLAS-${OPENBLAS_VERSION} \
      && echo "/usr/lib" >> /etc/ld.so.conf \
      && echo "/usr/lib64" >> /etc/ld.so.conf; \
    ldconfig -v | grep libopenblas

# # FFMPEG
# ENV FFMPEG_VESION=n7.1
# RUN apt-get install -y --no-install-recommends \
#       perl yasm; \
#     git config --global advice.detachedHead false \
#       && git clone --depth 1 --branch ${FFMPEG_VESION} https://github.com/FFmpeg/FFmpeg.git /tmp/FFmpeg-${FFMPEG_VESION} \
#       && loc=$(pwd) && cd /tmp/FFmpeg-${FFMPEG_VESION} \
#       && ./configure --prefix=/usr --enable-gpl --enable-shared --disable-programs --disable-doc --disable-debug --disable-stripping \
#       && make -j $(nproc) all && make -j $(nproc) install \
#       && cd ${loc} && rm -rf /tmp/FFmpeg-${FFMPEG_VESION} \
#       && echo "/usr/lib" >> /etc/ld.so.conf \
#       && echo "/usr/lib64" >> /etc/ld.so.conf; \
#     ldconfig -v | grep libav
