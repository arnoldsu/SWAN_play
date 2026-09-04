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
