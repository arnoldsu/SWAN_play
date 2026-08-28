#!/bin/bash
set -euo pipefail

demo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
archive="${demo_root}/swan4151.tar.gz"
source_dir="${demo_root}/swan4151"

if [[ ! -f "${archive}" ]]; then
    echo "Missing ${archive}" >&2
    echo "Download SWAN 41.51 from https://swanmodel.sourceforge.io/download/download.htm" >&2
    exit 1
fi

if [[ ! -d "${source_dir}" ]]; then
    tar -xzf "${archive}" -C "${demo_root}"
fi

module purge
module load gcc/12.2.0

cd "${source_dir}"
make config
make -j "${NCPUS:-8}" ser
test -x swan.exe
echo "SWAN installed: ${source_dir}/swan.exe"

