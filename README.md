# SRP-sliding-dynamics

Input files for the molecular dynamics simulations of cyclodextrin (CD) rings threaded on
poly(ethylene glycol) (PEG) — the single-ring polyrotaxanes and dimers that are the molecular
building blocks of **slide-ring polymers (SRPs)** — used to study ring sliding/diffusivity and
dimer binding free energies under applied tension.

These are **inputs only** (topologies, force-field parameters, run parameters, starting
structures, and PLUMED inputs). Trajectories and other large outputs are **not** included.

## Layout

```
forcefield/                shared force field (identical across all systems)
  gaff2.itp  tip3p.itp  PEG_30_c_GMX.itp
  MOL_aCD-OH.itp  MOL_aCD-OC.itp  MOL_gCD-OH.itp  MOL_gCD-OC.itp   (per CD type)
mdp/                       shared GROMACS run parameters
  0_minim.mdp  1_equil.mdp  2_NPT.mdp  3_NVT.mdp
unbiased/<CD>/<chem>/<state>/<length>/    diffusivity (unbiased) runs
biased/<CD>/<chem>/<config>/<length>/     OPES binding-free-energy runs
```

Each leaf folder contains its unique inputs (`topol.top`, starting `.gro`, and `plumed.dat`
for biased runs) plus a `run.sh` template. The `topol.top` `#include` lines point to the
shared `forcefield/` directory.

## System key

- **CD**: `aCDs` = α-CD, `gCDs` = γ-CD (+1 PEG), `gCDd` = γ-CD (+2 PEG, double-threaded)
- **chem**: `OH` = native CD, `OC` = permethylated (PM-) CD
- **state** (unbiased): `0` = single ring (monomer); `1`/`2`/`3` = two-ring dimer (FT/TT/FF)
- **config** (biased): `1`/`2`/`3` = dimer orientation FT/TT/FF
- **length** `lN`: the extent of the simulation box along the chain (*z*) axis in nm, which sets the extension — and hence the applied tension — on the PEG chain. `l8` = 8 nm, `l9` = 9 nm, …, `l14` = 14 nm. The labels `l16`–`l19` denote additional *intermediate* box lengths (not 16–19 nm) used to add extra tension points. `aCDs_trans/` = PEG restrained to the all-trans backbone conformation.

## Running a simulation

From any leaf folder (mdps are referenced from the repo-root `mdp/`):

```bash
cd unbiased/aCDs/OH/0/l8
bash run.sh          # em -> equil -> NPT -> NVT
```

```bash
cd biased/aCDs/OH/3/l11
bash run.sh          # OPES production with plumed.dat
```

`run.sh` is a template — adjust GROMACS/cluster settings for your environment.
Requires GROMACS (patched with PLUMED for the biased runs).

**Starting structures.** Unbiased runs start from the solvated structure `system-water.gro`,
which is energy-minimized in the first step of `run.sh`. Biased runs start from the provided
pre-minimized structure `0_em.gro`.

## Citation

If you use these inputs, please cite the accompanying paper. A preprint is available on
ChemRxiv: https://chemrxiv.org/doi/full/10.26434/chemrxiv.15005291/v1 (journal reference to
be updated upon publication).

Trajectory data are not included in this repository and are available from the corresponding
author on request.
