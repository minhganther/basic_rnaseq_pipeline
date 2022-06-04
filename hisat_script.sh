#!/usr/bin/env bash

## ----------------------------------------
## JOB SUBMIT SCRIPT FOR HISAT
## Task: Align trimmed fastq to reference genome
## ----------------------------------------

#SBATCH --job-name=hisat
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --time=0-6:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=8

	source $1
	
	input=$out_dir/trim/
	output=$out_dir/hisat/
	sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $2)
	
	export PATH=$PATH:/data/galaxy_server/galaxy/database/dependencies/_conda/bin/
    	source activate /data/eve_maize/aux/conda_sym/__hisat@2.1.0
	
	if [[ ${seq_type} = "pe" ]]
	then
		hisat2 -q -p $SLURM_CPUS_PER_TASK \
		-x ${ref_genome} \
		--rna-strandness FR \
		-1 ${input}/${sample}.trim_1P.fastq -2 ${input}/${sample}.trim_2P.fastq \
		-S ${output}/${sample}.sam
	elif [[ ${seq_type} = "pe" ]]
	then 
		hisat2 -q -p $SLURM_CPUS_PER_TASK \
		-x ${ref_genome}\
		-U ${input}/${sample}.trim.fastq \
		-S ${output}/${sample}.sam
	else 
		exit 1
	fi
	
	# Convert .sam to sorted .bam files
	samtools view -bS ${output}/${sample}.sam | samtools sort -o ${output}/${sample}.sort.bam
	rm -f ${output}/${sample}.sam # Remove sam files

	# MultiQC Report
        export PATH=$PATH:/data/galaxy_server/galaxy/database/dependencies/_conda/bin/
        source activate /data/eve_maize/aux/conda_sym/__multiqc@1.9

        multiqc -q -o ${out_dir}/multiqc/ -n multiqc_hisat_report.html ${output}/logs/
