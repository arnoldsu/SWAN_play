#!/bin/bash
set -e

echo
echo "========================================"
echo " 1. Creating bathymetry"
echo "========================================"

python scripts/make_bathymetry.py

echo
echo "========================================"
echo " 2. Running SWASH"
echo "========================================"

./run_ig20.sh

echo
echo "========================================"
echo " 3. Checking SWASH"
echo "========================================"

if grep -qi "Terminating error" Errfile 2>/dev/null ; then

    echo
    echo "SWASH TERMINATED:"
    cat Errfile
    echo
    echo "Check:"
    echo "    tail -100 PRINT"
    exit 1
fi

if [ ! -f output/eta.mat ]; then

    echo
    echo "ERROR: SWASH did not produce output/eta.mat"
    echo
    echo "Last PRINT lines:"
    tail -100 PRINT 2>/dev/null || true
    exit 1
fi

echo
echo "========================================"
echo " 4. Creating figures + animation"
echo "========================================"

python scripts/postprocess_ig20.py

echo
echo "========================================"
echo " DONE"
echo "========================================"

ls -lh figures/
