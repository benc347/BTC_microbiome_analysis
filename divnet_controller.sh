#!/bin/bash 

#SBATCH --time=48:00:00					##(day-hour:minute:second) sets the max time for the job
#SBATCH --cpus-per-task=4	 			##request number of cpus
#SBATCH --mem=12G						##max ram for the job

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=bienvenido.tibbs-cortes@usda.gov		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="00_run_multiple_divnet_%j"		##names what slurm logfile will be saved to 

# This script controls divnet jobs and makes subdirectories

# NEED TO CREATE A CONDA ENVIRONMENT FIRST
# at least on Ceres, there's some issues with using modules as dependencies, so use a conda env instead
# module load miniconda
# conda create --prefix /path/to/your/new/conda/env
# source activate /path/to/your/new/conda/env
# conda install -c gcc (v13.1.0) openblas (v0.3.23) rust (v1.71.1)

# clone in divnet-rs from git
# git clone https://github.com/mooreryan/divnet-rs.git --branch master

# build the divnet-rs package from the git object
# cargo build --release

# run tests to be sure divnet-rs is working properly
# target/release/divnet-rs supplementary_files/test_files/small/config_small.toml
# cargo test

#copy files from divnet_input directory to their own directories
for countfile in divnet_input/counts*.csv; do
	
	#create subdirectories for pairwise comparison_name
	#copy counts and samdata files into each directory
	comparison_name1="${countfile%.csv}"
	comparison_name2="${comparison_name1//counts_/}"
	workdir=$(pwd)
	mkdir ${comparison_name2##*/}
	cp $countfile ${countfile/counts_/samdata_} ${comparison_name2##*/}/
	
	#need to edit the config file
	cp config_main.toml ${comparison_name2##*/}/config.toml
	cd ${comparison_name2##*/}/	
	
	#need to use @ as the delimiter for sed because parameter expansion of $workdir contains "/"
	sed -i "s@replace_me_with_counttable@${workdir}\/${comparison_name2##*/}\/counts_${comparison_name2##*/}.csv@" ./config.toml
	sed -i "s@replace_me_with_samdata@${workdir}\/${comparison_name2##*/}\/samdata_${comparison_name2##*/}.csv@" ./config.toml
	sed -i "s@replace_me_with_this_directory@${workdir}\/${comparison_name2##*/}\/${comparison_name2##*/}_output.csv@" ./config.toml
	sed -i "s/replace_me_with_random/$RANDOM/" ./config.toml
	
	cd ../
	
	#need to edit the divnet script
	
	cp divnet_main.sh divnet_temp.sh
	sed -i "s/replace_me_with_configpath/${comparison_name2##*/}\/config.toml/" divnet_temp.sh
	sed -i "s/-divnet/-divnet_${comparison_name2##*/}/" divnet_temp.sh
	
	#run divnet-rs
	sbatch divnet_temp.sh
	
	sleep 5
	
	rm divnet_temp.sh
	
done

