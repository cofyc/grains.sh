#!/bin/sh
#
# A single shell script to gather basic information on Linux host.
#

#
# `grain_get_linux_os` returns Linux OS distribution name.
#
# Possible values:
#
#   MacOS
#   Ubuntu
#   alpine
#   ...
#
function grain_get_linux_os() {
    if `which lsb_release &>/dev/null`; then
        lsb_release -i | awk -F ':\t' '{print $2}'
    elif [ -f /etc/redhat-release ]; then
        cat /etc/redhat-release | sed 's/ Linux release.*//'
    elif [ -f /etc/lsb-release ]; then
        cat /etc/lsb-release | awk -F'=' '/^DISTRIB_ID/ {print $2}'
    elif [ -f /etc/os-release ]; then
        cat /etc/os-release | awk -F'=' '/^ID/ {print $2}'
    else
        # TODO support more
        "UNKOWN"
    fi
}

#
# `grain_get_linux_os_release` returns Linux OS distribution release version.
#
# Possible values:
#
#   10.11.6
#   ...
#
function grain_get_linux_os_release() {
    if `which lsb_release &>/dev/null`; then
        lsb_release -r | awk -F ':\t' '{print $2}'
    elif [ -f /etc/os-release ]; then
        (source /etc/os-release; echo $VERSION_ID)
    elif [ -f /etc/lsb-release ]; then
        cat /etc/lsb-release | awk -F'=' '/^DISTRIB_RELEASE/ {print $2}'
    else
        # TODO support more
        "UNKOWN"
    fi
}


#
# `grains_get_cpu_model` returns CPU model.
#
# Possible values:
#
# Intel(R) Core(TM) i7-4850HQ CPU @ 2.30GHz
#
function grains_get_cpu_model() {
    local model=$(lscpu | awk -F ': +' '/^Model name:/ { print $2 }')
    if [ -z "$model" ]; then
        model=$(cat /proc/cpuinfo | awk -F': +' '/model name/ { print $2 }' | head -n 1)
    fi
    if [ -z "$model" ]; then
        model=UNKOWN
    fi
    echo $model
}

GRAIN_HOSTNAME=$(hostname)
GRAIN_PLATFORM=$(uname -s)
if [[ "$GRAIN_PLATFORM" == "Linux" ]]; then
    GRAIN_KERNEL=$(uname -s)
    GRAIN_KERNEL_RELEASE=$(uname -r)
    GRAIN_OS=$(grain_get_linux_os)
    GRAIN_OS_RELEASE=$(grain_get_linux_os_release)
    GRAIN_CPU_NUM=$(lscpu | awk -F ': +' '/^CPU\(s\):/ { print $2 }')
    GRAIN_CPU_ARCH=$(lscpu | awk -F ': +' '/^Architecture:/ { print $2 }')
    GRAIN_CPU_MODEL=$(grains_get_cpu_model)
    GRAIN_MEM_TOTAL=$(( $(cat /proc/meminfo | awk '/^MemTotal:/ {print $2}') * 1024 ))
elif [[ "$GRAIN_PLATFORM" == "Darwin" ]]; then
    GRAIN_KERNEL=$(uname -s)
    GRAIN_KERNEL_RELEASE=$(uname -r)
    GRAIN_OS="MacOS"
    GRAIN_OS_RELEASE=$(sw_vers -productVersion)
    GRAIN_CPU_NUM=$(sysctl -n hw.ncpu)
    GRAIN_CPU_ARCH=$(sysctl -n hw.machine)
    GRAIN_CPU_MODEL=$(sysctl -n machdep.cpu.brand_string)
    GRAIN_MEM_TOTAL=$(sysctl -n hw.memsize)
else
    >&2 echo "Unsupport platform: ${GRAIN_PLATFORM}"
fi

# See http://stackoverflow.com/a/23009039/288089.
if [ "$0" = "$BASH_SOURCE" ]; then
    for v in $(compgen -v | grep '^GRAIN_'); do
        echo "$v=${!v}"
    done
else
    :
fi
