# basic_rnaseq_pipeline
A very basic RNAseq pipeline for processing raw fastq files to a gene count table

## Steps
1. FastQC: Creates a quality report for fastq sequence files
2. MultiQC: Creates summary reports for log files
3. Trimmomatic: Trims adapters and low quality bases
4. HISAT: Aligns and maps sequences to reference genome
5. Featurecounts: Counts gene features
