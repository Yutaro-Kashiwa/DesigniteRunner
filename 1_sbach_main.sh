#!/bin/bash

#SBATCH --job-name=designite
#SBATCH --output=logs/main_%A_%a.out
#SBATCH --error=errors/main_%A_%a.err
#SBATCH --array=1-300
#SBATCH --time=100:00:00
#SBATCH --partition=cluster_long
#SBATCH --ntasks=1
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8

mkdir -p errors
mkdir -p logs

echo bash main.bash $SLURM_ARRAY_TASK_ID