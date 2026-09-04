#!/bin/bash
set -e

# ============================================================
# SWASH paper-like infragravity experiment
#
# Albuquerque, Weppe & Berthot (2023)
# "On the use of instrumental data for infragravity
#  wave simulations"
#
# First experiment:
#   Ig20
#   Hs     = 2.18 m
#   Tp     = 16.7 s
#   Dir    = 164.5 deg
#   Spread = 26.4 deg
#
# This is a simplified harbour, NOT the exact Eastland Port
# bathymetry.
# ============================================================

ROOT=$(pwd)

SWASH=/scratch/p66/ars599/SWAN_play/swash-12.01/swash.exe

mkdir -p bathy input output figures scripts logs

# ============================================================
# 1. CREATE BATHYMETRY
# ============================================================

cat > scripts/make_bathymetry.py <<'PY'
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

dx = 5.0
dy = 5.0

Lx = 2000.0
Ly = 1500.0

nx = int(Lx/dx) + 1
ny = int(Ly/dy) + 1

x = np.arange(nx)*dx
y = np.arange(ny)*dy

X,Y = np.meshgrid(x,y)

# Offshore -> coast
depth = 20.0 - 12.0*(X/Lx)
depth = np.clip(depth,8.0,20.0)

# shallow coastal/reef areas
reef = (
    ((X > 1050) & (X < 1450) & (Y < 350)) |
    ((X > 1350) & (Y > 1150))
)

depth[reef] = np.minimum(depth[reef],3.0)

# harbour basin
basin = (
    (X > 1200) &
    (X < 1850) &
    (Y > 450) &
    (Y < 1050)
)

depth[basin] = 10.0

# harbour walls
wall = np.zeros_like(depth,dtype=bool)

wall |= (
    (X > 1200) & (X < 1850) &
    (Y > 430) & (Y < 460)
)

wall |= (
    (X > 1200) & (X < 1850) &
    (Y > 1040) & (Y < 1070)
)

wall |= (
    (X > 1820) & (X < 1850) &
    (Y > 430) & (Y < 1070)
)

# west wall with harbour entrance
wall |= (
    (X > 1180) & (X < 1220) &
    (
        ((Y > 430) & (Y < 650)) |
        ((Y > 850) & (Y < 1070))
    )
)

depth[wall] = 0.05

# inner pier
pier = (
    (X > 1500) &
    (X < 1530) &
    (Y > 700) &
    (Y < 950)
)

depth[pier] = 0.05

Path("bathy").mkdir(exist_ok=True)
Path("figures").mkdir(exist_ok=True)

np.savetxt(
    "bathy/bottom.bot",
    depth,
    fmt="%8.3f"
)

fig,ax = plt.subplots(figsize=(10,7))

cf=ax.contourf(
    X/1000,
    Y/1000,
    depth,
    levels=np.arange(0,22,2)
)

plt.colorbar(cf,ax=ax,label="Water depth (m)")

ax.contour(
    X/1000,
    Y/1000,
    depth,
    levels=[5,10,15],
    linewidths=0.7
)

ax.set_xlabel("X (km)")
ax.set_ylabel("Y (km)")
ax.set_title("Simplified paper-like harbour bathymetry")
ax.set_aspect("equal")

plt.tight_layout()
plt.savefig(
    "figures/fig01_bathymetry.png",
    dpi=180
)

print("Bathymetry:",depth.shape)
print("Depth:",depth.min(),depth.max())
PY


# ============================================================
# 2. SWASH INPUT — IG20 JONSWAP
# ============================================================

cat > input/ig20_jonswap.sws <<'EOF'
PROJECT 'IG20' '01'

SET NAUTICAL

CGRID REGULAR 0. 0. 0. 2000. 1500. 400 300

INPGRID BOTTOM REGULAR 0. 0. 0. 400 300 5. 5.
READINP BOTTOM 1. 'bathy/bottom.bot' 1 0 FREE

INIT ZERO

BOUND SHAPESPEC JONSWAP 3.3 PEAK DSPR DEGREES
BOUNDCOND SIDE WEST CCW CONSTANT SPECTRUM 2.18 16.7 164.5 26.4

FRICTION MANNING 0.019

NONHYDROSTATIC

TIMEI METH EXPL

BLOCK 'COMPGRID' NOHEAD 'output/eta.mat' LAY 3 XP YP DEP BOTLEV WATL OUTPUT 000000.000 2. SEC

COMPUTE 000000.000 0.05 SEC 003000.000

STOP
EOF


# ============================================================
# 3. RUN SCRIPT
# ============================================================

cat > run_ig20.sh <<EOF
#!/bin/bash

set -e

SWASH="$SWASH"

rm -f INPUT PRINT Errfile

cp input/ig20_jonswap.sws INPUT

# Set QUICK_TEST=1 for a 60 s smoke test; the permanent input remains 1800 s.
if [ "\${QUICK_TEST:-0}" = "1" ]; then
    sed -i 's/003000\\.000/000100.000/' INPUT
fi

echo "========================================"
echo " Running SWASH Ig20"
echo "========================================"

if ! \$SWASH > logs/ig20_stdout.log 2>&1; then
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
EOF

chmod +x run_ig20.sh


# ============================================================
# 4. PYTHON POSTPROCESSING + ANIMATION
# ============================================================

cat > scripts/postprocess_ig20.py <<'PY'
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, PillowWriter
from scipy.io import loadmat
from scipy.signal import butter, sosfiltfilt, welch

FILE="output/eta.mat"

if not os.path.exists(FILE):
    raise SystemExit(
        "\nERROR: output/eta.mat does not exist.\n"
        "Check PRINT and Errfile first.\n"
    )

print("Reading:",FILE)

D=loadmat(FILE)

print("\nVariables in SWASH output:")
for k in D:
    if not k.startswith("__"):
        try:
            print(k, np.asarray(D[k]).shape)
        except Exception:
            print(k)

# ------------------------------------------------------------
# Automatically search for water-level arrays
# ------------------------------------------------------------

candidates=[]

for k,v in D.items():

    if k.startswith("__"):
        continue

    a=np.asarray(v)

    if a.ndim >= 2:
        candidates.append((k,a))

print("\nCandidate arrays:")

for k,a in candidates:
    print(k,a.shape)

# SWASH MATLAB BLOCK output often uses time-labelled WATL arrays.
water=[]

for k,a in candidates:

    ku=k.upper()

    if "WATL" in ku or "WATLEV" in ku:
        water.append((k,np.squeeze(a)))

if not water:

    raise SystemExit(
        "\nCould not automatically identify WATL.\n"
        "Variables are printed above; inspect eta.mat.\n"
    )

print("\nWater-level frames:",len(water))

# sort variable names by SWASH output order
water=sorted(water,key=lambda z:z[0])

# ------------------------------------------------------------
# Coordinates
# ------------------------------------------------------------

nx=401
ny=301

x=np.arange(nx)*5.0
y=np.arange(ny)*5.0

# ------------------------------------------------------------
# Read frames
# ------------------------------------------------------------

frames=[]

for name,a in water:

    a=np.squeeze(a)

    # expected SWASH field ny x nx
    if a.shape == (ny,nx):
        frames.append(a)

    elif a.shape == (nx,ny):
        frames.append(a.T)

if not frames:

    raise SystemExit(
        "Found WATL variables but dimensions do not match grid."
    )

eta=np.asarray(frames)

print("eta shape =",eta.shape)

# output interval from INPUT
dt=2.0

time=np.arange(len(eta))*dt

# ------------------------------------------------------------
# 5. WAVE ANIMATION
# ------------------------------------------------------------

print("\nCreating wave animation...")

fig,ax=plt.subplots(figsize=(10,7))

v=np.nanpercentile(np.abs(eta),99)

if not np.isfinite(v) or v == 0:
    v=1.0

im=ax.imshow(
    eta[0],
    origin="lower",
    extent=[0,2.0,0,1.5],
    vmin=-v,
    vmax=v,
    interpolation="bilinear",
    aspect="equal"
)

cb=plt.colorbar(im,ax=ax)
cb.set_label("Surface elevation η (m)")

title=ax.set_title("")

ax.set_xlabel("X (km)")
ax.set_ylabel("Y (km)")

def update(i):

    im.set_data(eta[i])

    title.set_text(
        f"SWASH Ig20 — t = {time[i]:.0f} s"
    )

    return im,title

# animate every 2nd stored frame
ids=np.arange(0,len(eta),2)

ani=FuncAnimation(
    fig,
    update,
    frames=ids,
    interval=60,
    blit=False
)

ani.save(
    "figures/ig20_wave_animation.gif",
    writer=PillowWriter(fps=15)
)

plt.close()

print("Created figures/ig20_wave_animation.gif")


# ------------------------------------------------------------
# 6. HARBOUR TIME SERIES
# ------------------------------------------------------------

# point inside harbour
ix=int(1650/5)
iy=int(750/5)

z=eta[:,iy,ix]

fig,ax=plt.subplots(figsize=(11,4))

ax.plot(time,z)

ax.set_xlabel("Time (s)")
ax.set_ylabel("η (m)")
ax.set_title("SWASH surface elevation inside harbour")

plt.tight_layout()

plt.savefig(
    "figures/fig02_eta_harbour.png",
    dpi=180
)

plt.close()


# ------------------------------------------------------------
# 7. SPECTRUM
# ------------------------------------------------------------

fs=1/dt

f,P=welch(
    z-np.mean(z),
    fs=fs,
    nperseg=min(512,len(z))
)

period=np.full_like(f,np.nan)

period[1:]=1/f[1:]

fig,ax=plt.subplots(figsize=(9,5))

ax.plot(period[1:],P[1:])

ax.set_xlim(300,5)
ax.set_yscale("log")

ax.axvspan(
    25,
    250,
    alpha=0.15
)

ax.set_xlabel("Period (s)")
ax.set_ylabel("PSD")
ax.set_title("Harbour wave spectrum — IG band 25–250 s")

plt.tight_layout()

plt.savefig(
    "figures/fig03_harbour_spectrum.png",
    dpi=180
)

plt.close()


# ------------------------------------------------------------
# 8. 25–250 s BANDPASS
# ------------------------------------------------------------

f_low=1/250
f_high=1/25

sos=butter(
    4,
    [f_low,f_high],
    btype="bandpass",
    fs=fs,
    output="sos"
)

print("\nCalculating HsIG map...")

hsig=np.full((ny,nx),np.nan)

for j in range(ny):

    if j % 25 == 0:
        print("row",j,"/",ny)

    for i in range(nx):

        zz=eta[:,j,i]

        if np.any(~np.isfinite(zz)):
            continue

        try:

            zig=sosfiltfilt(
                sos,
                zz-np.mean(zz)
            )

            # significant IG wave height
            hsig[j,i]=4*np.std(zig)

        except Exception:
            pass


# ------------------------------------------------------------
# 9. HsIG MAP
# ------------------------------------------------------------

fig,ax=plt.subplots(figsize=(10,7))

im=ax.imshow(
    hsig,
    origin="lower",
    extent=[0,2.0,0,1.5],
    aspect="equal"
)

plt.colorbar(
    im,
    ax=ax,
    label=r"$H_{sIG}$ (m)"
)

ax.set_xlabel("X (km)")
ax.set_ylabel("Y (km)")

ax.set_title(
    "SWASH Ig20 — Infragravity wave height (25–250 s)"
)

plt.tight_layout()

plt.savefig(
    "figures/fig04_ig20_HsIG.png",
    dpi=180
)

plt.close()


# ------------------------------------------------------------
# 10. IG TIME SERIES
# ------------------------------------------------------------

zig=sosfiltfilt(
    sos,
    z-np.mean(z)
)

fig,ax=plt.subplots(figsize=(11,4))

ax.plot(time,z,label="Total η")
ax.plot(time,zig,label="25–250 s IG")

ax.set_xlabel("Time (s)")
ax.set_ylabel("η (m)")
ax.set_title("Harbour surface elevation and infragravity component")

ax.legend()

plt.tight_layout()

plt.savefig(
    "figures/fig05_ig_timeseries.png",
    dpi=180
)

plt.close()

print("\n========================================")
print("POSTPROCESSING COMPLETE")
print("========================================")

print("""
Products:

figures/fig01_bathymetry.png
figures/fig02_eta_harbour.png
figures/fig03_harbour_spectrum.png
figures/fig04_ig20_HsIG.png
figures/fig05_ig_timeseries.png
figures/ig20_wave_animation.gif
""")
PY


# ============================================================
# 5. MASTER SCRIPT
# ============================================================

cat > run_all.sh <<'EOF'
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
EOF

chmod +x run_all.sh

echo
echo "========================================"
echo "CASE CREATED"
echo "========================================"
echo
echo "Run:"
echo
echo "    ./run_all.sh"
echo
