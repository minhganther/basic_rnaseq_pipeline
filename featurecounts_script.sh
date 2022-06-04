#!/usr/bin/env bash

## ----------------------------------------
## JOB SUBMIT SCRIPT FOR FEATURECOUNTS
## Task: Count gene features
## ----------------------------------------

#SBATCH --job-name=featcts
#SBATCH --mail-type=ALL
#SBATCH --time=0-6:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=8

	source $1
	input=$out_dir/hisat/
	output=$out_dir/featurecounts/	
	
	if [[ $seq_type = "pe" ]]
	then
		FC_OPTIONS=$(echo "-p -s ${stranded}")
	fi

	export PATH=$PATH:/data/galaxy_server/galaxy/database/dependencies/_conda/bin/
    	source activate /data/eve_maize/aux/conda_sym/__subread@1.6.3

	cd $input
    	featureCounts -T $SLURM_CPUS_PER_TASK -t exon -g gene_id -a $ref_gtf \
	--primary -O --largestOverlap $FC_OPTIONS \
	-o counts.txt ./*.sort.bam

	mv counts* ../featurecounts/

	# MULTIQC
        export PATH=$PATH:/data/galaxy_server/galaxy/database/dependencies/_conda/bin/
        source activate /data/eve_maize/aux/conda_sym/__multiqc@1.9

        multiqc -q -o ${out_dir}/multiqc/ -n multiqc_counts_report.html $output	
