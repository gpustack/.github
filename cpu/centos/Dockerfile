ARG BASE_VERSION=7


FROM centos:${BASE_VERSION}
SHELL ["/bin/bash", "-c"]

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
ENV PKG_CONFIG_PATH="/opt/rh/devtoolset-9/root/usr/lib/pkgconfig:/opt/rh/devtoolset-9/root/usr/lib64/pkgconfig:$PKG_CONFIG_PATH" \
    LD_LIBRARY_PATH="/opt/rh/devtoolset-9/root/usr/lib:/opt/rh/devtoolset-9/root/usr/lib/dyninst:/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib64/dyninst:$LD_LIBRARY_PATH"
RUN yum install -y devtoolset-9 devtoolset-9-libatomic-devel devtoolset-9-elfutils-libelf-devel \
      && ln -vsf /opt/rh/devtoolset-9/root/bin/* /usr/bin/ \
      && echo "/opt/rh/devtoolset-9/root/usr/lib" >> /etc/ld.so.conf \
      && echo "/opt/rh/devtoolset-9/root/usr/lib64" >> /etc/ld.so.conf \
      && ldconfig -v \
      && gcc --version
RUN yum install -y glibc-static libstdc++-static

# OPENSSL
ENV OPENSSL_VESION=3.4.0 \
    PKG_CONFIG_PATH="/usr/local/openssl/lib/pkgconfig:/usr/local/openssl/lib64/pkgconfig:$PKG_CONFIG_PATH" \
    LD_LIBRARY_PATH="/usr/local/openssl/lib:/usr/local/openssl/lib64:$LD_LIBRARY_PATH"
RUN yum install -y zlib-devel perl perl-IPC-Cmd perl-Test-Simple perl-CPAN \
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
RUN yum install -y openblas-static
COPY <<EOF /usr/lib64/pkgconfig/openblas.pc
Name: OpenBLAS
Description: OpenBLAS library
Version: 0.3.3
Libs: -L/usr/lib64 -lopenblas
Cflags: -I/usr/include/openblas
EOF

# OPENMP
RUN yum install -y libgomp openmpi openmpi-devel
