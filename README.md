# SWAN and ROMS coastal-model playground

This repository records independently verified coastal-model builds and demonstrations on NCI Gadi:

- **SWAN 41.51**: stationary waves entering from the western offshore boundary and transforming across a 50-to-2 m coastal slope.
- **SWASH 12.01**: compiled standalone serial executable for non-hydrostatic wave and flow simulations.
- **ROMS official Upwelling test**: a one-day, wind-driven 3-D coastal upwelling simulation with Fennel biogeochemistry.

The standalone tests establish that the compiler, runtime and plotting environments work. The next stage is to build the official COAWST Inlet Test, which couples the ROMS and SWAN versions distributed inside COAWST.

## Verified environment

The runs documented here completed on Gadi on 28 August 2026.

| Component | Verified value |
|---|---|
| SWAN | 41.51 |
| SWASH | 12.01 |
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
├── swash-12.01/                 SWASH source and serial executable
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

## 2. Build SWASH

SWASH 12.01 was compiled and verified on Gadi on 4 September 2026. The
platform configurator selects the available GNU Fortran compiler, but can add
the GCC-10-only `-fallow-argument-mismatch` option when an older GFortran is
in use. Override the generated fixed-form flags at build time:

```bash
cd /scratch/p66/ars599/SWAN_play/swash-12.01
. /etc/bashrc
module purge
make config
make ser FLAGS_MSC='-w -fno-second-underscore'
```

The resulting serial executable is `swash-12.01/swash.exe`. The same override
can be used to verify the adjacent SWAN build:

```bash
cd /scratch/p66/ars599/SWAN_play/swan4151
. /etc/bashrc
module purge
make config
make ser FLAGS_MSC='-w -fno-second-underscore'
```

Both executables were checked as 64-bit Linux ELF binaries with no unresolved
dynamic libraries.

## 3. Install ROMS

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

## 4. Run and plot ROMS

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

## 5. ROMS–SWAN coupling

Standalone executables are not connected directly. COAWST supplies compatible ROMS and SWAN source plus a native two-way coupler. The smallest next demonstration is its official Inlet Test, which provides the ocean grid, wave grid, interpolation weights, coupling interval, boundary waves, wetting/drying and optional sediment configuration.

The coupled exchange is:

```text
ROMS -> SWAN: currents, water level and bathymetry
SWAN -> ROMS: wave height, period, direction and wave forcing
```

For a real coastline, replace the idealized inputs with bathymetry/shoreline, an ocean grid and initial/boundary state, tides and atmospheric forcing, and offshore wave spectra.

### Joint animation (independent-output diagnostic)

Run `./scripts/run_roms_swan_animation.sh` to create
`figures/ROMS_SWAN_joint_diagnostic.gif`. It combines real transient ROMS
sea-level/current output with real stationary SWAN wave output. It is labelled
as an independent-output diagnostic because the present standalone builds do
not exchange fields. For regional wind-wave coupling use **SWAN**; use SWASH
for short-scale non-hydrostatic surf-zone, harbour, or overtopping studies.

## 6. Run the ROMS + SWAN joint demonstration

### 6.1 Run the complete workflow

```bash
cd /scratch/p66/ars599/SWAN_play
./scripts/run_swan_demo.sh
./scripts/run_roms_demo.sh
./scripts/run_roms_swan_animation.sh
```

These commands create and run the idealized SWAN coastal case, run the
official ROMS Upwelling case for one simulated day, and read both real model
outputs to create the joint GIF. If the model outputs already exist, run only
the final command to regenerate the animation.

### 6.2 Pre-run checks

```bash
test -x swan4151/swan.exe
test -x ROMS/roms_test/upwelling/romsS
test -s playground01/swan_output.dat
test -s ROMS/roms_test/upwelling/roms_his.nc
```

If either executable is missing, first follow the installation procedures in
Sections 1 and 3.

### 6.3 Success checks and outputs

```bash
grep 'accuracy OK in 100.00' playground01/PRINT
grep 'ROMS: DONE' ROMS/roms_test/upwelling/roms_run.log
```

| File | Contents |
|---|---|
| `playground01/swan_output.dat` | SWAN depth, significant wave height, period, and direction |
| `ROMS/roms_test/upwelling/roms_his.nc` | ROMS sea level, 3-D velocity, and hydrographic variables |
| `figures/SWAN_wave_height.png` | SWAN significant-wave-height map |
| `figures/ROMS_upwelling_summary.png` | ROMS final-state summary |
| `figures/ROMS_SWAN_joint_diagnostic.gif` | Joint current, wind-stress, and wave animation |

## 7. Running concept

### 7.1 Idealized coast and physical processes

SWAN uses a 100 km by 50 km regular domain. Water depth decreases from 50 m
at the western offshore boundary to 2 m at the eastern coast. A JONSWAP
spectrum with Hs=2 m and Tp=8 s enters through the western boundary. SWAN
calculates changes caused by propagation, shoaling, breaking, and bottom
friction.

ROMS uses the official idealized Upwelling case. Analytical alongshore wind
stress drives the surface current and cross-shore transport. The model
calculates time-dependent sea level, velocity, temperature, salinity, and
biogeochemical variables. The current history file contains five animation
times: 0, 6, 12, 18, and 24 hours.

In the joint GIF:

- Colors in the ROMS panel show sea level; colored arrows show surface-current
  direction and relative speed.
- Magenta arrows show the prescribed alongshore wind-stress direction. The
  history file does not contain 10 m wind speed, so arrow length must not be
  interpreted as wind speed.
- Colors in the SWAN panel show significant wave height (`Hs`); orange arrows
  show the direction of wave propagation.
- Moving white crests are an animation cue only; the SWAN solution is
  stationary.

### 7.2 Current status and true coupling

The workflow runs real ROMS and SWAN simulations, but they are independent
cases on different grids and do not exchange fields during execution. The
joint GIF verifies that both models and their outputs work; it is not evidence
of two-way coupling.

True two-way coupling should use COAWST:

```text
Atmospheric forcing --> ROMS --sea level, currents, depth--> SWAN
                         ^                                  |
                         +--wave height, period, direction--+
```

During every coupling interval, ROMS updates sea level and currents; the
coupler interpolates those fields onto the SWAN grid; SWAN updates the wave
spectrum; and wave height, period, direction, and wave forces are returned to
ROMS. The next step is to run the official COAWST Inlet Test, then replace its
inputs with the target coastline, bathymetry, tides, atmospheric forcing,
ocean boundaries, and offshore wave spectra.

### 7.3 SWAN or SWASH?

Use **SWAN** for this project. It is a phase-averaged spectral wave model
suited to regional kilometre-scale wind waves and wave-current interaction,
and it has a mature COAWST ROMS-SWAN coupling interface.

SWASH is a non-hydrostatic, phase-resolving model suited to individual waves,
breaking, harbour oscillations, overtopping, and inundation in much smaller
domains. Its spatial and temporal resolution requirements are substantially
higher, and it is not a direct replacement for this regional ROMS-SWAN
coupling workflow.

## Reproducibility checks

```bash
test -x swan4151/swan.exe
test -x swash-12.01/swash.exe
grep 'accuracy OK in 100.00' playground01/PRINT
test -x ROMS/roms_test/upwelling/romsS
grep 'ROMS: DONE' ROMS/roms_test/upwelling/roms_run.log
ncdump -h ROMS/roms_test/upwelling/roms_his.nc | grep -E 'NH4|oxygen|TIC|alkalinity'
```

Downloaded source trees, object files and large NetCDF outputs are intentionally excluded from Git. Recreate them with the scripts above.
