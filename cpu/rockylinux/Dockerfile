ARG BASE_VERSION=8.9


FROM rockylinux:${BASE_VERSION}

# SOURCE
RUN dnf install -y epel-release \
      && dnf config-manager --set-enabled powertools

# MAKE & CCACHE & CURL & GIT
RUN yum install -y make ccache curl git \
      && make --version \
      && ccache --version \
      && curl --version \
      && git --version

# CMAKE
ENV CMAKE_VERSION=3.22.1
RUN curl -sL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-$(uname -m).tar.gz" | tar -zx -C /usr --strip-components 1 \
      && cmake --version

# GCC
ENV PKG_CONFIG_PATH="/opt/rh/gcc-toolset-11/root/usr/lib/pkgconfig:/opt/rh/gcc-toolset-11/root/usr/lib64/pkgconfig:$PKG_CONFIG_PATH" \
    LD_LIBRARY_PATH="/opt/rh/gcc-toolset-11/root/usr/lib:/opt/rh/gcc-toolset-11/root/usr/lib/dyninst:/opt/rh/gcc-toolset-11/root/usr/lib64:/opt/rh/gcc-toolset-11/root/usr/lib64/dyninst:$LD_LIBRARY_PATH"
RUN dnf install -y binutils pkgconfig gcc gcc-c++ gcc-toolset-11 \
      && ln -vsf /opt/rh/gcc-toolset-11/root/bin/* /usr/bin/ \
      && echo "/opt/rh/gcc-toolset-11/root/usr/lib" >> /etc/ld.so.conf \
      && echo "/opt/rh/gcc-toolset-11/root/usr/lib64" >> /etc/ld.so.conf \
      && ldconfig -v \
      && gcc --version
RUN dnf install -y glibc-static libstdc++-static

# OPENSSL
ENV OPENSSL_VESION=3.4.0
RUN dnf install -y perl \
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
RUN dnf install -y perl yasm \
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
