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
RUN apt-get install -y libssl-dev

# OPENBLAS
RUN apt-get install -y libopenblas-dev

# OPENMP
RUN apt-get install -y libgomp1 libomp-dev
