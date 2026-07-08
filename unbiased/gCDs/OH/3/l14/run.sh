#!/bin/bash
#SBATCH --job-name=srp_unbiased
#SBATCH --output=out-gpu.out
#SBATCH --error=error-gpu.out
#SBATCH --partition=andrewferguson-gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --account=pi-andrewferguson

# Shared run-parameter files live in the repository-root mdp/ directory.
MDP=../../../../../mdp

module load gromacs/2025.1
echo "Running on host: $(hostname)"

# Step 0: energy minimization (from the solvated structure system-water.gro)
echo "=== Step 0: 0_minim (EM) ==="
gmx_mpi grompp -f $MDP/0_minim.mdp -c system-water.gro -p topol.top -o 0_em.tpr -maxwarn 1
(time gmx_mpi mdrun -v -deffnm 0_em -ntomp 8) 2>&1

# Step 1: NVT equilibration
echo "=== Step 1: 1_equil (NVT) ==="
gmx_mpi grompp -f $MDP/1_equil.mdp -c 0_em.gro    -p topol.top -o 1_equil.tpr -nobackup -maxwarn 1
(time gmx_mpi mdrun -v -deffnm 1_equil -ntomp 8 -nb gpu -pme gpu) 2>&1

# Step 2: NPT equilibration  (15_NPTb intentionally skipped)
echo "=== Step 2: 2_NPT (NPT) ==="
gmx_mpi grompp -f $MDP/2_NPT.mdp   -c 1_equil.gro -p topol.top -o 2_NPT.tpr   -maxwarn 1
(time gmx_mpi mdrun -deffnm 2_NPT -ntomp 8 -nb gpu -pme gpu) 2>&1

# Step 3: NVT production
echo "=== Step 3: 3_NVT (NVT) ==="
gmx_mpi grompp -f $MDP/3_NVT.mdp   -c 2_NPT.gro   -p topol.top -o 3_NVT.tpr   -maxwarn 1
(time gmx_mpi mdrun -deffnm 3_NVT -ntomp 8 -nb gpu -pme gpu) 2>&1
