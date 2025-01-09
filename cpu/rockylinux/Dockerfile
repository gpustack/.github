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
ENV OPENSSL_VESION=3.4.0 \
    PKG_CONFIG_PATH="/usr/local/openssl/lib/pkgconfig:/usr/local/openssl/lib64/pkgconfig:$PKG_CONFIG_PATH" \
    LD_LIBRARY_PATH="/usr/local/openssl/lib:/usr/local/openssl/lib64:$LD_LIBRARY_PATH"
RUN dnf install -y zlib-devel perl \
      && curl -sL "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VESION}/openssl-${OPENSSL_VESION}.tar.gz" | tar -zx -C /tmp \
      && loc=$(pwd) && cd /tmp/openssl-${OPENSSL_VESION} \
      && ./config --prefix=/usr/local/openssl --openssldir=/etc/ssl shared enable-ssl3 enable-ssl3-method enable-mdc2 enable-md2 \
      && make -j $(nproc) build_sw && make -j $(nproc) install_sw \
      && cd ${local} && rm -rf /tmp/openssl-${OPENSSL_VESION} \
      && ln -vsf /usr/local/openssl/bin/* /usr/bin/ \
      && ln -vsf /usr/local/openssl/include/openssl /usr/include/openssl \
      && echo "/usr/local/openssl/lib" >> /etc/ld.so.conf \
      && echo "/usr/local/openssl/lib64" >> /etc/ld.so.conf \
      && ldconfig -v \
      && openssl --version

# OPENBLAS
RUN dnf install -y openblas-static

# OPENMP
RUN yum install -y libgomp openmpi openmpi-devel

