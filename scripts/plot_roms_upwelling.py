#!/usr/bin/env python3
"""Plot physical and biogeochemical fields from the ROMS Upwelling test."""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import xarray as xr


INPUT = Path(__file__).resolve().parents[1] / "ROMS" / "roms_test" / "upwelling" / "roms_his.nc"
OUTPUT = Path(__file__).resolve().parents[1] / "figures" / "ROMS_upwelling_summary.png"


def surface(field: xr.DataArray) -> xr.DataArray:
    """Select the final time and, for 3-D fields, the surface level."""
    indexers = {"ocean_time": -1}
    if "s_rho" in field.dims:
        indexers["s_rho"] = -1
    return field.isel(indexers)


def panel(ax, field, title, label, cmap="viridis"):
    image = ax.pcolormesh(field, shading="auto", cmap=cmap)
    ax.set_title(title)
    ax.set_xlabel("xi grid index")
    ax.set_ylabel("eta grid index")
    plt.colorbar(image, ax=ax, label=label, shrink=0.86)


with xr.open_dataset(INPUT, decode_times=False) as ds:
    temperature = surface(ds["temp"])
    sea_level = surface(ds["zeta"])
    ammonium = surface(ds["NH4"])
    oxygen = surface(ds["oxygen"])

    fig, axes = plt.subplots(2, 2, figsize=(13, 10), constrained_layout=True)
    panel(axes[0, 0], temperature, "Surface temperature", "degrees C", "turbo")
    panel(axes[0, 1], sea_level, "Sea-surface height", "m", "RdBu_r")
    panel(axes[1, 0], ammonium, "Surface ammonium (NH4)", "mmol N m$^{-3}$", "YlGn")
    panel(axes[1, 1], oxygen, "Surface dissolved oxygen", "mmol O$_2$ m$^{-3}$", "Blues")

    fig.suptitle(
        "ROMS official Upwelling test: final state after 1 simulated day",
        fontsize=15,
    )
    fig.savefig(OUTPUT, dpi=180)

    for name, field in {
        "temp": temperature,
        "zeta": sea_level,
        "NH4": ammonium,
        "oxygen": oxygen,
    }.items():
        values = np.asarray(field)
        print(
            f"{name}: min={np.nanmin(values):.6g}, "
            f"max={np.nanmax(values):.6g}, finite={np.isfinite(values).all()}"
        )

print(f"Created {OUTPUT}")
