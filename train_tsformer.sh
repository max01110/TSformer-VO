#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --account=rrg-swasland
#SBATCH --mail-user=max.michet@mail.utoronto.ca
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:a100:1
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --array=1-1%1
#SBATCH --job-name=tsformer
#SBATCH --output=./logs/%x/%j.out

# Load environment and CUDA version

module load StdEnv/2020
module load python/3.8.2
module load cuda/11.4
module load gcc opencv/4.5.1

workdir=/home/$USER/projects/rrg-swasland/$USER/TSformer-VO
cd $workdir 

source TSformer-VO/bin/activate

# Unzip datasets to $SLURM_TMPDIR (scratch space)
unzip -qq /home/$USER/projects/rrg-swasland/datasets/KITTI_odometry/data_odometry_gray.zip -d $SLURM_TMPDIR
unzip -qq /home/$USER/projects/rrg-swasland/datasets/KITTI_odometry/data_odometry_poses.zip -d $SLURM_TMPDIR


# Run image conversion
python png_to_jpg.py \
    --dataset_dir $SLURM_TMPDIR/dataset/sequences \
    --output_dir $SLURM_TMPDIR/sequences_jpg

rm -f data/poses
rm -f data/sequences_jpg

ln -s $SLURM_TMPDIR/dataset/poses $workdir/data
ln -s $SLURM_TMPDIR/sequences_jpg $workdir/data

python3 train.py
