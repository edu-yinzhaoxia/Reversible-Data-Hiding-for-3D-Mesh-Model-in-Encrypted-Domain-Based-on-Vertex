#!/bin/bash
#SBATCH --job-name=huffman
#SBATCH -N1
#SBATCH --gres=gpu:2 #GPU
#SBATCH --cpus-per-task=1 
#SBATCH --mem=20G
#SBATCH -o %j.log 
#SBATCH -e %j.err 
#SBATCH -p GPU8
echo $(hostname) $CUDA_VISIBLE_DEVICES
srun /Share/apps/singularity/bin/singularity exec /Share/imgs/ahu_ai.img bash /Share/apps/matlab/R2016a/bin/matlab  -nodesktop -nosplash -r 'cd /Share/home/D11714020/huffman_improve;AdoptMain;exit;'
