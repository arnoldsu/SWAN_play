#!/bin/bash

set -e

SWASH="/scratch/p66/ars599/SWAN_play/swash-12.01/swash.exe"

rm -f INPUT PRINT Errfile

cp input/ig20_jonswap.sws INPUT

# Set QUICK_TEST=1 for a 60 s smoke test; the permanent input remains 1800 s.
if [ "${QUICK_TEST:-0}" = "1" ]; then
    sed -i 's/003000\.000/000100.000/' INPUT
fi

echo "========================================"
echo " Running SWASH Ig20"
echo "========================================"

if ! $SWASH > logs/ig20_stdout.log 2>&1; then
    echo "SWASH executable returned a failure status" >&2
    exit 1
fi

cp PRINT logs/PRINT_ig20 2>/dev/null || true
cp Errfile logs/Errfile_ig20 2>/dev/null || true

echo
echo "========================================"
echo " SWASH finished"
echo "========================================"

if [ -f Errfile ]; then
    echo
    echo "Errfile:"
    cat Errfile
fi

echo
echo "Output directory:"
ls -lh output || true
