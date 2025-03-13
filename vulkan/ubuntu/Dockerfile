ARG BASE_VERSION=22.04

FROM ubuntu:${BASE_VERSION}
SHELL ["/bin/bash", "-c"]

ARG VULKAN_VERSION=1.3.296

# VULKAN
ENV DEBIAN_FRONTEND=noninteractive
RUN source /etc/os-release; \
      apt-get update -y \
        && apt-get install -y wget gnupg; \
      wget -qO - https://packages.lunarg.com/lunarg-signing-key-pub.asc | apt-key add -; \
	wget -qO /etc/apt/sources.list.d/lunarg-vulkan-${VULKAN_VERSION}-${VERSION_CODENAME}.list https://packages.lunarg.com/vulkan/${VULKAN_VERSION}/lunarg-vulkan-${VULKAN_VERSION}-${VERSION_CODENAME}.list; \
	apt update -y \
	  && apt install -y vulkan-sdk

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
ENV CMAKE_VERSION=3.22.1
RUN curl -sL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-$(uname -m).tar.gz" | tar -zx -C /usr --strip-components 1 \
      && cmake --version

# GCC
RUN apt-get install -y binutils pkg-config gfortran gcc-11 g++-11 gfortran-11; \
      if [ -f /etc/alternatives/gcov-dump ]; then update-alternatives --remove-all gcov-dump; fi; update-alternatives --install /usr/bin/gcov-dump gcov-dump /usr/bin/gcov-dump-11 10; \
      if [ -f /etc/alternatives/lto-dump ]; then update-alternatives --remove-all lto-dump; fi; update-alternatives --install /usr/bin/lto-dump lto-dump /usr/bin/lto-dump-11 10; \
      if [ -f /etc/alternatives/gcov ]; then update-alternatives --remove-all gcov; fi; update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-11 10; \
      if [ -f /etc/alternatives/gcc ]; then update-alternatives --remove-all gcc; fi; update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 10; \
      if [ -f /etc/alternatives/gcc-nm ]; then update-alternatives --remove-all gcc-nm; fi; update-alternatives --install /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-11 10; \
      if [ -f /etc/alternatives/cpp ]; then update-alternatives --remove-all cpp; fi; update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-11 10; \
      if [ -f /etc/alternatives/g++ ]; then update-alternatives --remove-all g++; fi; update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 10; \
      if [ -f /etc/alternatives/gcc-ar ]; then update-alternatives --remove-all gcc-ar; fi; update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-11 10; \
      if [ -f /etc/alternatives/gcov-tool ]; then update-alternatives --remove-all gcov-tool; fi; update-alternatives --install /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-11 10; \
      if [ -f /etc/alternatives/gcc-ranlib ]; then update-alternatives --remove-all gcc-ranlib; fi; update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-11 10; \
      if [ -f /etc/alternatives/gfortran ]; then update-alternatives --remove-all gfortran; fi; update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-11 10; \
      ldconfig -v \
      && gcc --version
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
