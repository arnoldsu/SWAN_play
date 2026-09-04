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
