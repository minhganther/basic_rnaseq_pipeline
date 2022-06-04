#!/usr/bin/env bash

## ----------------------------------------
## JOB SUBMIT SCRIPT FOR TRIMMOMATIC
## Task: Remove adapters and trim raw .fastq files
## ----------------------------------------

#SBATCH --job-name=trim
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --time=0-2:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=8

	source $1
	
	input=$input_dir
	output=$out_dir/trim 
	seq_type=$seq_type
	sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $2)
	
    # Set Conda environment, all conda are symlinked in /data/eve_maize/aux/conda_sym
	export PATH=$PATH:/data/galaxy_server/galaxy/database/dependencies/_conda/bin/
	source activate /data/eve_maize/aux/conda_sym/__trimmomatic@0.36

    # Trimmomatic command
	if [[ ${seq_type} = "pe" ]]
	then
		trimmomatic PE -threads $SLURM_CPUS_PER_TASK \
		${input}/*${sample}*_R1_*.fastq* ${input}/*${sample}*_R2_*.fastq* -baseout ${output}/${sample}.trim.fastq  \
		${TRIM_OPTIONS}
	elif [[ ${seq_type} = "se" ]]
	then
		trimmomatic SE -threads $SLURM_CPUS_PER_TASK \
		${input}/${sample}*.fastq* \
		${TRIM_OPTIONS}
	else
		exit 1
	fi

	# MultiQC Report
        export PATH=$PATH:/data/galaxy_server/galaxy/database/dependencies/_conda/bin/
        source activate /data/eve_maize/aux/conda_sym/__multiqc@1.9

        multiqc -q -o ${out_dir}/multiqc/ -n multiqc_trim_report.html ${output}/logs/
