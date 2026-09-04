#!/usr/bin/env python3
"""Animate real ROMS and SWAN outputs side by side (independent runs)."""
from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, PillowWriter
import numpy as np
import xarray as xr

ROOT = Path(__file__).resolve().parents[1]
ROMS = ROOT / "ROMS/roms_test/upwelling/roms_his.nc"
SWAN = ROOT / "playground01/swan_output.dat"
OUT = ROOT / "figures/ROMS_SWAN_joint_diagnostic.gif"

with xr.open_dataset(ROMS, decode_times=False) as ds:
    hours = np.asarray(ds.ocean_time) / 3600
    zeta = np.asarray(ds.zeta)
    u = np.asarray(ds.u.isel(s_rho=-1))
    v = np.asarray(ds.v.isel(s_rho=-1))
ur = .5 * (u[:, 1:-1, :-1] + u[:, 1:-1, 1:])
vr = .5 * (v[:, :-1, 1:-1] + v[:, 1:, 1:-1])
ry, rx = np.mgrid[1:zeta.shape[1]-1, 1:zeta.shape[2]-1]

d = np.loadtxt(SWAN)
sx, sy = d[:, 0] / 1000, d[:, 1] / 1000
nx, ny = np.unique(sx).size, np.unique(sy).size
X, Y = sx.reshape(ny, nx), sy.reshape(ny, nx)
depth, hs = d[:, 2].reshape(ny, nx), d[:, 3].reshape(ny, nx)
direction = np.deg2rad(d[:, 5].reshape(ny, nx))
wx, wy = -np.sin(direction), -np.cos(direction)
zmax = max(np.nanpercentile(np.abs(zeta), 99), 1e-4)

fig, axes = plt.subplots(1, 2, figsize=(12, 5.2))
fig.subplots_adjust(bottom=.18, top=.84, wspace=.28)

def frame(k):
    for ax in axes:
        ax.clear()
    a, b = axes
    im1 = a.pcolormesh(zeta[k], cmap="RdBu_r", shading="auto", vmin=-zmax, vmax=zmax)
    sk = (slice(None, None, 5), slice(None, None, 4))
    speed = np.hypot(ur[k], vr[k])
    un = np.divide(ur[k], speed, out=np.zeros_like(ur[k]), where=speed > 0)
    vn = np.divide(vr[k], speed, out=np.zeros_like(vr[k]), where=speed > 0)
    a.quiver(rx[sk], ry[sk], un[sk], vn[sk], speed[sk], cmap="viridis",
             angles="xy", scale_units="xy", scale=.42, width=.004)
    # UPWELLING prescribes uniform equatorward wind stress analytically. Wind
    # speed itself is not written to this history file, so only direction is shown.
    for xpos in (.12, .25, .38):
        a.annotate("", (xpos, .73), (xpos, .91), xycoords="axes fraction",
                   arrowprops=dict(arrowstyle="->", color="magenta", lw=2.2))
    a.text(.1, .94, "prescribed wind-stress direction", color="magenta",
           transform=a.transAxes, fontsize=8)
    a.set(title=f"ROMS: sea level, current and wind stress, t={hours[k]:.0f} h", xlabel="cross-shore grid", ylabel="alongshore grid")
    im2 = b.pcolormesh(X, Y, hs, cmap="Blues", shading="auto")
    b.contour(X, Y, depth, [5, 10, 20, 30, 40], colors=".4", linewidths=.5)
    ss = (slice(None, None, 7), slice(None, None, 10))
    b.quiver(X[ss], Y[ss], wx[ss], wy[ss], color="darkorange", scale=18, width=.004)
    for crest in np.arange(-20 + 4*k, 100, 14):
        b.plot([crest, crest], [1, 49], color="white", alpha=.3)
    b.fill_between([96, 103], 0, 50, color="#d8c39b")
    b.plot([96, 96], [0, 50], color="#765b32", lw=2)
    b.text(98, 25, "idealized coast", rotation=90, va="center")
    b.set(xlim=(0, 103), ylim=(0, 50), title="SWAN: Hs and wave propagation direction",
          xlabel="offshore boundary to coast (km)", ylabel="alongshore distance (km)")
    fig.suptitle("ROMS + SWAN joint diagnostic (real independent outputs; not coupled yet)", weight="bold")
    if k == 0 and len(fig.axes) == 2:
        c1 = fig.add_axes([.13, .07, .31, .025])
        fig.colorbar(im1, cax=c1, orientation="horizontal").set_label("sea level (m)")
        c2 = fig.add_axes([.59, .07, .31, .025])
        fig.colorbar(im2, cax=c2, orientation="horizontal").set_label("significant wave height Hs (m)")

ani = FuncAnimation(fig, frame, frames=len(hours), interval=900, repeat=True)
OUT.parent.mkdir(exist_ok=True)
ani.save(OUT, writer=PillowWriter(fps=1.1), dpi=110)
plt.close(fig)
print(f"Created {OUT}")
print("PROVENANCE: real ROMS output + real SWAN output; independent, not coupled")
