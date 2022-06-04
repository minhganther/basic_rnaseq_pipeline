#!/bin/bash

# Run the pipeline with
# sh rnaseq_pipe.sh CONFIG_FILE SAMPLE_NAMES

work_dir=$PWD
out_dir=$work_dir/$out_dir
input_dir=$work_dir/$input_dir
config=$work_dir/$1
sample_names=$work_dir/$2
number_of_samples=$(sed -n '$=' ${sample_names})

source $config

echo "Using this input folder: $input_dir"
echo "Using this output folder: $out_dir"
echo "Using this config file: $config"
echo "Using this sample file: $sample_names"
echo "Number of samples: ${number_of_samples}"

mkdir -p $out_dir/trim/logs
mkdir -p $out_dir/fastqc/logs/
mkdir -p $out_dir/fastqc/logs/
mkdir -p $out_dir/hisat/logs/
mkdir -p $out_dir/featurecounts/logs/
mkdir -p $out_dir/multiqc/

# FASTQC
jid1=$(sbatch --parsable -o $out_dir/fastqc/logs/%x-%j.out -e $out_dir/fastqc/logs/%x-%j.err /data/eve_maize/scripts/minh/fastqc_script.sh $input_dir $out_dir/fastqc/)
echo "FastQC: Job ID $jid1 is running..."

# TRIMMING
jid2=$(sbatch --parsable --array=1-${number_of_samples} -o $out_dir/trim/logs/%x-%A-%a.out -e $out_dir/trim/logs/%x-%A-%a.err /data/eve_maize/scripts/minh/trimmomatic_script.sh $config $sample_names)
echo "Trimming: Job ID $jid2 is running..."

# HISAT
jid3=$(sbatch --parsable --dependency=afterok:$jid2 --array=1-${number_of_samples} -o $out_dir/hisat/logs/%x-%A-%a.out -e $out_dir/hisat/logs/%x-%A-%a.err /data/eve_maize/scripts/minh/hisat_script.sh $config $sample_names)
echo "HISAT: Job ID $jid3 is running..."

# FEATURECOUNTS
jid4=$(sbatch --parsable --dependency=afterok:$jid3 -o $out_dir/featurecounts/logs/%x-%j.out -e $out_dir/featurecounts/logs/%x-%j.err /data/eve_maize/scripts/minh/featurecounts_script.sh $config)
echo "featurecounts: Job ID $jid4 is running..."
