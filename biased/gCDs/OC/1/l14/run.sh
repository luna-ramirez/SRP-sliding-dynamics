#!/bin/bash
#SBATCH --job-name=srp_biased
#SBATCH --output=out-gpu.out
#SBATCH --error=error-gpu.out
#SBATCH --partition=andrewferguson-gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --gres=gpu:1
#SBATCH --account=pi-andrewferguson

# Shared run-parameter files live in the repository-root mdp/ directory.
MDP=../../../../../mdp

# GROMACS + PLUMED environment
module purge
module load slurm/current
module load rcc/default
module load gcc/12.2.0
module load cuda/12.9
module load openmpi/5.0.2+gcc-12.2.0
module load fftw3/3.3.9
echo "Running on host: $(hostname)"
gmx_mpi mdrun -h | grep -i plumed

# OPES production: equilibration .mdp + PLUMED bias, from the minimized 0_em.gro.
# (-nsteps is the full production length; lower it for a quick test run.)
echo "=== OPES production (1_equil.mdp + plumed.dat) ==="
gmx_mpi grompp -f $MDP/1_equil.mdp -c 0_em.gro -p topol.top -o 1_equil.tpr -maxwarn 1 -v
(time gmx_mpi mdrun -deffnm 1_equil -ntomp $SLURM_CPUS_PER_TASK -nb gpu -pme gpu \
    -plumed plumed.dat -v -nobackup -nsteps 100000000) 2>&1
