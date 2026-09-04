#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test -s "${root}/ROMS/roms_test/upwelling/roms_his.nc"
test -s "${root}/playground01/swan_output.dat"
module purge
module load conda/analysis3-26.01
export PYTHONNOUSERSITE=1
python3 "${root}/scripts/plot_roms_swan_animation.py"
