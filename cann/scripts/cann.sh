#!/bin/bash

set -e

get_architecture() {
    # not case sensitive
    shopt -s nocasematch

    case "${PLATFORM}" in
        "linux/x86_64"|"linux/amd64")
            ARCH="x86_64"
            ;;
        "linux/aarch64"|"linux/arm64")
            ARCH="aarch64"
            ;;
        *)
            echo "Error: Unsupported architecture ${PLATFORM}."
            exit 1
            ;;
    esac

    echo "${ARCH}"
}

download_file() {
    set +e

    local max_retries=10
    local retry_delay=10
    local url="$1"
    local path="$2"

    for ((i=1; i<=max_retries; i++)); do
        echo "Attempt $i of $max_retries..."
        curl -H 'Referer: https://www.hiascend.com/' -fSL -o "${path}" "${url}"
        if [[ $? -eq 0 ]]; then
            return 0
        else
            echo "Download failed with error code $?. Retrying in ${retry_delay} seconds..."
            sleep ${retry_delay}
        fi
    done

    echo "All attempts failed. Exiting."
    return 1
}

detect_cann() {
    local url_prefix="https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%20${CANN_DOWNLOAD_VERSION}"
    local url_suffix="response-content-type=application/octet-stream"
    local url="${url_prefix}/${1}?${url_suffix}"

    curl -H 'Referer: https://www.hiascend.com/' -fsSIL "${url}" >/dev/null 2>&1
}

download_cann() {
    local url_prefix="https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%20${CANN_DOWNLOAD_VERSION}"
    local url_suffix="response-content-type=application/octet-stream"
    local toolkit_url="${url_prefix}/${TOOLKIT_FILE}?${url_suffix}"
    local kernels_url="${url_prefix}/${KERNELS_FILE}?${url_suffix}"
    local nnal_url="${url_prefix}/${NNAL_FILE}?${url_suffix}"

    if [ ! -f "${TOOLKIT_PATH}" ]; then
        echo "Downloading ${TOOLKIT_FILE} from ${toolkit_url}"
        download_file "${toolkit_url}" "${TOOLKIT_PATH}"
    fi

    if [ ! -f "${KERNELS_PATH}" ]; then
        echo "Downloading ${KERNELS_FILE} from ${kernels_url}"
        download_file "${kernels_url}" "${KERNELS_PATH}"
    fi

    if [ ! -f "${NNAL_PATH}" ]; then
        echo "Downloading ${NNAL_FILE} from ${nnal_url}"
        download_file "${nnal_url}" "${NNAL_PATH}"
    fi

    echo "CANN ${CANN_VERSION} download successful."
}

set_env() {
    local cann_toolkit_env_file="${CANN_HOME}/ascend-toolkit/set_env.sh"
    if [ ! -f "${cann_toolkit_env_file}" ]; then
        echo "CANN Toolkit ${CANN_VERSION} installation failed."
        exit 1
    else
        local driver_path_env="LD_LIBRARY_PATH=${CANN_HOME}/driver/lib64/common/:${CANN_HOME}/driver/lib64/driver/:\${LD_LIBRARY_PATH}" && \
        echo "export ${driver_path_env}" >> /etc/profile
        echo "export ${driver_path_env}" >> ~/.bashrc
        echo "source ${cann_toolkit_env_file}" >> /etc/profile
        echo "source ${cann_toolkit_env_file}" >> ~/.bashrc
        source ${cann_toolkit_env_file}
    fi
}

install_cann() {
    # Download installers
    if [ ! -f "${TOOLKIT_PATH}" ] || [ ! -f "${KERNELS_PATH}" ]; then
        echo "[WARNING] Installers do not exist, re-download them."
        download_cann
    fi

    # Install dependencies
    pip install --no-cache-dir --upgrade pip
    pip install --no-cache-dir \
        attrs cython numpy decorator sympy cffi pyyaml pathlib2 psutil protobuf scipy requests absl-py

    # Install CANN Toolkit
    echo "Installing ${TOOLKIT_FILE}"
    chmod +x "${TOOLKIT_PATH}"
    bash "${TOOLKIT_PATH}" --quiet --install --install-for-all --install-path="${CANN_HOME}"
    rm -f "${TOOLKIT_PATH}"

    # Set environment variables
    set_env

    # Install CANN Kernels
    echo "Installing ${KERNELS_FILE}"
    chmod +x "${KERNELS_PATH}"
    bash "${KERNELS_PATH}" --quiet --install --install-for-all --install-path="${CANN_HOME}"
    rm -f "${KERNELS_PATH}"

    # Install CANN Nnal
    echo "Installing ${NNAL_FILE}"
    chmod +x "${NNAL_PATH}"
    bash "${NNAL_PATH}" --quiet --install --install-path="${CANN_HOME}"
    rm -f "${NNAL_PATH}"

    echo "CANN ${CANN_VERSION} installation successful."
}

PLATFORM="${PLATFORM:=$(uname -s)/$(uname -m)}"
ARCH="$(get_architecture)"
CANN_HOME="${CANN_HOME:="/usr/local/Ascend"}"
CANN_CHIP="${CANN_CHIP:="910b"}"
CANN_VERSION="${CANN_VERSION:="8.0.RC2.beta1"}"
CANN_DOWNLOAD_VERSION="${CANN_VERSION%\.beta1}"

TOOLKIT_FILE="Ascend-cann-toolkit_${CANN_DOWNLOAD_VERSION}_linux-${ARCH}.run"
KERNELS_FILE="Ascend-cann-kernels-${CANN_CHIP}_${CANN_DOWNLOAD_VERSION}_linux-${ARCH}.run"
if ! detect_cann "${KERNELS_FILE}"; then
    KERNELS_FILE="Ascend-cann-kernels-${CANN_CHIP}_${CANN_DOWNLOAD_VERSION}_linux.run"
fi
NNAL_FILE="Ascend-cann-nnal_${CANN_DOWNLOAD_VERSION}_linux-${ARCH}.run"
TOOLKIT_PATH="/tmp/${TOOLKIT_FILE}"
KERNELS_PATH="/tmp/${KERNELS_FILE}"
NNAL_PATH="/tmp/${NNAL_FILE}"

echo "TOOLKIT_FILE=${TOOLKIT_FILE}"
echo "KERNELS_FILE=${KERNELS_FILE}"
echo "NNAL_FILE=${NNAL_FILE}"

# Parse arguments
if [ "$1" == "--download" ]; then
    download_cann
elif [ "$1" == "--install" ]; then
    install_cann
elif [ "$1" == "--set_env" ]; then
    set_env
else
    echo "Unexpected arguments, use '--download', '--install' or '--set_env' instead"
    exit 1
fi
