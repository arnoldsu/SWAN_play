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
