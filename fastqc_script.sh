#!/usr/bin/env bash

## ----------------------------------------
## JOB SUBMIT SCRIPT FOR FASTQC
## Task: Create a FastQC report for all files in a given folder
## ----------------------------------------

#SBATCH --job-name=fastqc
#SBATCH --mail-type=ALL
#SBATCH --time=0-6:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=2

	input=$1
	output=$2 # /output_folder/fastqc/

	# FASTQC
	module load FastQC/0.11.9-Java-1.8
	fastqc -q -t $SLURM_CPUS_PER_TASK -o ${output} ${input}/*fastq* 
	
	# MULTIQC
	export PATH=$PATH:/data/galaxy_server/galaxy/database/dependencies/_conda/bin/
        source activate /data/eve_maize/aux/conda_sym/__multiqc@1.9

	multiqc -q ${output} 
