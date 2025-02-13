#!/bin/bash 

#SBATCH --partition=short
#SBATCH --time=48:00:00					##(day-hour:minute:second) sets the max time for the job
#SBATCH --cpus-per-task=96	 			##request number of cpus
#SBATCH --mem=290G						##max ram for the job

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=bienvenido.tibbs-cortes@usda.gov		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="00-divnet_%j"		##names what slurm logfile will be saved to 

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
## slurm break

# working in a conda environment, so load it
module load miniconda
source activate /project/ibdru_bioinformatics/Ben/conda_envs/divnet_env

OPENBLAS_NUM_THREADS=1 RUST_LOG=trace /project/ibdru_bioinformatics/Ben/conda_envs/divnet_env/divnet-rs/target/release/divnet-rs replace_me_with_configpath