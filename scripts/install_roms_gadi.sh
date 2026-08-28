#!/bin/bash
set -euo pipefail

demo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
roms_root="${demo_root}/ROMS"
source_dir="${roms_root}/roms"
test_dir="${roms_root}/roms_test"
case_dir="${test_dir}/upwelling"

mkdir -p "${roms_root}"
if [[ ! -d "${source_dir}/.git" ]]; then
    git clone --branch main --depth 1 https://github.com/myroms/roms.git "${source_dir}"
fi
if [[ ! -d "${test_dir}/.git" ]]; then
    git clone --branch main --depth 1 https://github.com/myroms/roms_test.git "${test_dir}"
fi

# Gadi configuration: GNU serial build and GCC's matching preprocessor.
sed -i 's/^ export           USE_MPI=on/#export           USE_MPI=on/' "${case_dir}/build_roms.sh"
sed -i 's/^ export        USE_MPIF90=on/#export        USE_MPIF90=on/' "${case_dir}/build_roms.sh"
sed -i 's/^ export              FORT=ifort/#export              FORT=ifort/' "${case_dir}/build_roms.sh"
sed -i 's/^#export              FORT=gfortran/ export              FORT=gfortran/' "${case_dir}/build_roms.sh"
sed -i 's|^              CPP := /usr/bin/cpp|              CPP := /apps/gcc/12.2.0/bin/cpp|' "${source_dir}/Compilers/Linux-gfortran.mk"

module purge
module load gcc/12.2.0 netcdf/4.7.3

# Analysis3 may remain in PATH after module purge. Keep its linker out of this build.
export PATH=/apps/netcdf/4.7.3/bin:/apps/gcc/12.2.0/wrappers:/apps/gcc/12.2.0/bin:/usr/bin:/bin
export ROMS_ROOT_DIR="${roms_root}"
export NETCDF_INCDIR=/apps/netcdf/4.7.3/include/GNU

cd "${case_dir}"
./build_roms.sh -j "${NCPUS:-8}"
test -x romsS
echo "ROMS installed: ${case_dir}/romsS"

