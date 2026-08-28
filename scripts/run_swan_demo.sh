#!/bin/bash
set -e

# ============================================================
# SWAN PLAYGROUND 01
# Offshore waves -> shallow coast
# ============================================================

DEMO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${DEMO_ROOT}"

module purge
module load conda/analysis3-26.01
export PYTHONNOUSERSITE=1

mkdir -p playground01
cd playground01

SWAN="${DEMO_ROOT}/swan4151/swan.exe"

# ============================================================
# 1. Create bathymetry
# ============================================================

python3 - <<'PY'
import numpy as np

nx = 101
ny = 51

# Depth decreases from west -> east
depth_x = np.linspace(50.0, 2.0, nx)
depth = np.tile(depth_x, (ny, 1))

np.savetxt(
    "bottom.bot",
    depth,
    fmt="%.3f"
)

print("Created bottom.bot")
print("Grid shape:", depth.shape)
print("West/offshore depth:", depth[0, 0], "m")
print("East/coastal depth:", depth[0, -1], "m")
PY

# ============================================================
# 2. Create SWAN INPUT
# ============================================================

cat > INPUT <<'SWANEOF'
$ ============================================================
$ SIMPLE SWAN COASTAL WAVE EXPERIMENT
$ offshore -> coast
$ Hs = 2 m
$ Tp = 8 s
$ ============================================================

PROJECT 'PLAY01' '01'

MODE STAT
COORD CART

$ Computational grid
CGRID REGULAR 0 0 0 100000 50000 100 50 &
CIRCLE 36 0.04 1.0 25

$ Bathymetry
INPGRID BOTTOM REGULAR 0 0 0 100 50 1000 1000
READINP BOTTOM 1 'bottom.bot' 1 0 FREE

$ Offshore wave boundary
BOUND SHAPESPEC JONSWAP PEAK DSPR DEGREES
BOUNDSPEC SIDE W CCW CONSTANT PAR 2.0 8.0 270.0 25.0

$ Physics
$ No local wind is prescribed, so wind-wave quadruplet interactions are disabled.
OFF QUAD
BREAKING
FRICTION JONSWAP

$ Output
FRAME 'GRID' 0 0 0 100000 50000 100 50

TABLE 'GRID' NOHEAD 'swan_output.dat' &
XP YP DEP HSIGN RTP DIR

COMPUTE
STOP
SWANEOF

# ============================================================
# 3. Run SWAN
# ============================================================

echo
echo "======================================"
echo "RUNNING SWAN"
echo "======================================"

$SWAN

echo
echo "======================================"
echo "OUTPUT FILES"
echo "======================================"

ls -lh

echo
echo "First few SWAN output values:"
head swan_output.dat

# ============================================================
# 4. Create plotting script
# ============================================================

cat > plot_swan.py <<'PY'
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

data = np.loadtxt("swan_output.dat")

x = data[:, 0] / 1000.0
y = data[:, 1] / 1000.0
depth = data[:, 2]
hs = data[:, 3]
tp = data[:, 4]
direction = data[:, 5]

xu = np.unique(x)
yu = np.unique(y)

nx = len(xu)
ny = len(yu)

print("Grid:", nx, "x", ny)

X = x.reshape(ny, nx)
Y = y.reshape(ny, nx)

DEP = depth.reshape(ny, nx)
HS = hs.reshape(ny, nx)
TP = tp.reshape(ny, nx)

# ------------------------------------------------------------
# Plot 1: Hs map
# ------------------------------------------------------------

fig, ax = plt.subplots(figsize=(12, 5))

cf = ax.contourf(
    X,
    Y,
    HS,
    levels=20
)

plt.colorbar(
    cf,
    ax=ax,
    label="Significant Wave Height Hs (m)"
)

cs = ax.contour(
    X,
    Y,
    DEP,
    levels=[5, 10, 20, 30, 40],
    linewidths=0.7
)

ax.clabel(
    cs,
    fontsize=8,
    fmt="%d m"
)

ax.set_xlabel("Distance from offshore boundary (km)")
ax.set_ylabel("Alongshore distance (km)")
ax.set_title("SWAN: Wave propagation from offshore to shallow coast")

plt.tight_layout()
plt.savefig("SWAN_wave_height.png", dpi=200)
plt.close()

# ------------------------------------------------------------
# Plot 2: Cross-shore profile
# ------------------------------------------------------------

middle = ny // 2

fig, ax1 = plt.subplots(figsize=(10, 5))

ax1.plot(
    X[middle, :],
    HS[middle, :],
    linewidth=2
)

ax1.set_xlabel("Distance offshore -> coast (km)")
ax1.set_ylabel("Significant Wave Height Hs (m)")
ax1.grid(alpha=0.3)

ax2 = ax1.twinx()

ax2.plot(
    X[middle, :],
    DEP[middle, :],
    linestyle="--",
    linewidth=2
)

ax2.set_ylabel("Water depth (m)")
ax2.invert_yaxis()

plt.title("SWAN cross-shore wave transformation")
plt.tight_layout()
plt.savefig("SWAN_cross_shore.png", dpi=200)
plt.close()

print()
print("Created:")
print("SWAN_wave_height.png")
print("SWAN_cross_shore.png")
PY

# ============================================================
# 5. Plot
# ============================================================

python3 plot_swan.py

mkdir -p "${DEMO_ROOT}/figures"
cp SWAN_wave_height.png SWAN_cross_shore.png "${DEMO_ROOT}/figures/"

echo
echo "======================================"
echo "FINISHED"
echo "======================================"

ls -lh *.png
