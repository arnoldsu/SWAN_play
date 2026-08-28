#!/bin/bash
set -euo pipefail

demo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
case_dir="${demo_root}/ROMS/roms_test/upwelling"

test -x "${case_dir}/romsS"
module purge
module load gcc/12.2.0 netcdf/4.7.3
export PATH=/apps/netcdf/4.7.3/bin:/apps/gcc/12.2.0/wrappers:/apps/gcc/12.2.0/bin:/usr/bin:/bin

cd "${case_dir}"
./romsS < roms_upwelling.in > roms_run.log 2>&1
grep -q 'ROMS: DONE' roms_run.log
test -s roms_his.nc

module purge
module load conda/analysis3-26.01
export PYTHONNOUSERSITE=1
python3 "${demo_root}/scripts/plot_roms_upwelling.py"

echo "ROMS completed: ${case_dir}/roms_his.nc"
echo "Figure: ${demo_root}/figures/ROMS_upwelling_summary.png"

