# SWAN and ROMS coastal-model playground

This repository records two independently verified coastal-model demonstrations on NCI Gadi:

- **SWAN 41.51**: stationary waves entering from the western offshore boundary and transforming across a 50-to-2 m coastal slope.
- **ROMS official Upwelling test**: a one-day, wind-driven 3-D coastal upwelling simulation with Fennel biogeochemistry.

The standalone tests establish that the compiler, runtime and plotting environments work. The next stage is to build the official COAWST Inlet Test, which couples the ROMS and SWAN versions distributed inside COAWST.

## Verified environment

The runs documented here completed on Gadi on 28 August 2026.

| Component | Verified value |
|---|---|
| SWAN | 41.51 |
| ROMS source | official `myroms/roms`, commit `9cd517c` |
| ROMS tests | official `myroms/roms_test`, commit `7b287ce` |
| Fortran | GCC/GFortran 12.2.0 |
| NetCDF | NCI module 4.7.3, GNU Fortran interface |
| Plotting | `conda/analysis3-26.01`, with `PYTHONNOUSERSITE=1` |

## Directory layout

```text
SWAN_play/
├── README.md
├── scripts/                     reproducible install, run and plot scripts
├── figures/                     compact, version-controlled results
├── playground01/                generated SWAN inputs and output
├── swan4151/                    downloaded SWAN source/build (not in Git)
└── ROMS/
    ├── roms/                    official ROMS source (not in Git)
    └── roms_test/upwelling/     official test, executable and output (not in Git)
```

## 1. Install and run SWAN

Download the official `swan4151.tar.gz` archive from the [SWAN download page](https://swanmodel.sourceforge.io/download/download.htm) and place it in the repository root. The bundled `INSTALL.README` prescribes `make config` followed by `make ser`; the installer automates those commands with GFortran:

```bash
cd /scratch/p66/ars599/SWAN_play
./scripts/install_swan_gadi.sh
./scripts/run_swan_demo.sh
```

The case uses a 101×51 Cartesian grid covering 100×50 km. Depth decreases linearly from 50 m at the western boundary to 2 m at the coast. A JONSWAP spectrum with Hs=2 m and Tp=8 s enters from 270 degrees. Because no local wind is prescribed, `OFF QUAD` disables the incompatible zero-wind quadruplet interaction.

A successful run reports 100% of wet grid points meeting the convergence criterion and creates:

- `playground01/swan_output.dat`
- `figures/SWAN_wave_height.png`
- `figures/SWAN_cross_shore.png`

![SWAN wave height](figures/SWAN_wave_height.png)

![SWAN cross-shore profile](figures/SWAN_cross_shore.png)

## 2. Install ROMS

The installer clones the two official repositories and configures the analytical Upwelling case for a serial GNU build:

```bash
cd /scratch/p66/ars599/SWAN_play
./scripts/install_roms_gadi.sh
```

The Gadi-specific settings are important:

- NetCDF Fortran modules are in `/apps/netcdf/4.7.3/include/GNU`, not the generic include directory reported by `nf-config`.
- ROMS must use `/apps/gcc/12.2.0/bin/cpp` so the preprocessor matches GCC 12.
- Analysis3 leaves `/opt/conda/.../bin/ld` in `PATH` after `module purge`; the installer supplies a clean build `PATH` so ROMS links with `/usr/bin/ld` and resolves the NCI HDF5 dependencies.

Build products are placed in `ROMS/roms_test/upwelling/Build_roms/`; the final executable is `ROMS/roms_test/upwelling/romsS`.

## 3. Run and plot ROMS

```bash
cd /scratch/p66/ars599/SWAN_play
./scripts/run_roms_demo.sh
```

The official case has a 41×80 horizontal grid, 16 terrain-following levels, a 300 s time step and 288 steps (one simulated day). The verified serial run took about 65 seconds and ended with `ROMS: DONE`.

Principal output files are:

- `roms_his.nc`: five history records
- `roms_avg.nc`: four averaged records
- `roms_dia.nc`: physical and biological diagnostics
- `roms_rst.nc`: restart state
- `roms_sta.nc` and `roms_flt.nc`: stations and float trajectories

The enabled Fennel configuration includes NO3, NH4, TIC, alkalinity and dissolved oxygen. Diagnostics include surface pCO2 and air-sea CO2 flux. The summary plot shows final surface temperature, sea-surface height, NH4 and oxygen.

![ROMS upwelling summary](figures/ROMS_upwelling_summary.png)

Verified final surface ranges:

| Field | Minimum | Maximum |
|---|---:|---:|
| Temperature | 21.8728 °C | 21.9355 °C |
| Sea-surface height | -0.0115122 m | 0.0116776 m |
| NH4 | 0.0821047 mmol N m-3 | 0.0822411 mmol N m-3 |
| Dissolved oxygen | 259.168 mmol O2 m-3 | 303.266 mmol O2 m-3 |

## 4. ROMS–SWAN coupling

Standalone executables are not connected directly. COAWST supplies compatible ROMS and SWAN source plus a native two-way coupler. The smallest next demonstration is its official Inlet Test, which provides the ocean grid, wave grid, interpolation weights, coupling interval, boundary waves, wetting/drying and optional sediment configuration.

The coupled exchange is:

```text
ROMS -> SWAN: currents, water level and bathymetry
SWAN -> ROMS: wave height, period, direction and wave forcing
```

For a real coastline, replace the idealized inputs with bathymetry/shoreline, an ocean grid and initial/boundary state, tides and atmospheric forcing, and offshore wave spectra.

## Reproducibility checks

```bash
test -x swan4151/swan.exe
grep 'accuracy OK in 100.00' playground01/PRINT
test -x ROMS/roms_test/upwelling/romsS
grep 'ROMS: DONE' ROMS/roms_test/upwelling/roms_run.log
ncdump -h ROMS/roms_test/upwelling/roms_his.nc | grep -E 'NH4|oxygen|TIC|alkalinity'
```

Downloaded source trees, object files and large NetCDF outputs are intentionally excluded from Git. Recreate them with the scripts above.
