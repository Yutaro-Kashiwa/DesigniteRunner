#!/bin/bash

#SBATCH --job-name=designite
#SBATCH --output=logs/make-list_%A_%a.out
#SBATCH --error=errors/make-list_%A_%a.err
#SBATCH --array=1-500
#SBATCH --time=4:00:00
#SBATCH --partition=cluster_short
#SBATCH --ntasks=1
#SBATCH --mem=16G
#SBATCH --cpus-per-task=1

mkdir -p errors
mkdir -p logs
module load java
bash main.sh $SLURM_ARRAY_TASK_ID