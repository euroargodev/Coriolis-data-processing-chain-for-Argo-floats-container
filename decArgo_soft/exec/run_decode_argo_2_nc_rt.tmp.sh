#!/bin/sh
# Wrapper for decode_argo_2_nc_rt
# Accepts either MCRROOT (/mnt/runtime) or base dir (rsynclog) as first argument

exe_dir=$(dirname "$0")

DEFAULT_MCRROOT="/mnt/runtime"

# Detect if first argument is a valid directory (absolute path) for MCR
if [ -d "$1" ] && [ -f "$1/runtime/glnxa64/libmwlaunchermain.so" ]; then
    MCRROOT="$1"
    shift 1
else
    MCRROOT="$DEFAULT_MCRROOT"
fi

# Build LD_LIBRARY_PATH
LD_LIBRARY_PATH=.:${MCRROOT}/runtime/glnxa64
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/opengl/lib/glnxa64
export LD_LIBRARY_PATH
echo "LD_LIBRARY_PATH is ${LD_LIBRARY_PATH}"


# Preload glibc_shim if needed
test -e /usr/bin/ldd && ldd --version | grep -q "(GNU libc) 2\.17" \
    && export LD_PRELOAD="${MCRROOT}/bin/glnxa64/glibc-2.17_shim.so"

# Pass all remaining args to the binary
args="$@"
eval "\"${exe_dir}/decode_argo_2_nc_rt\"" $args