#!/bin/bash

mamba activate reads_env

mamba install -c bioconda porechop
mamba install -c bioconda nextflow
mamba install -c bioconda trimmomatic


# -------------------------------------
# # short reads preprocessing # #

trimmomatic PE -threads 50 -phred33 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-Illumina_QCVTS273D5_QCVTS279DJ_21045b240_R1.fastq.gz 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-Illumina_QCVTS273D5_QCVTS279DJ_21045b240_R2.fastq.gz -baseout Cmic_Illu.fq.gz ILLUMINACLIP:adapt.fa:2:30:10

# -------------------------------------
# # ONT reads preprocessing # #

porechop -i 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01.fastq.gz -o 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01_CLEAN.fq --discard_middle 

# ------------------------------------
# # QUALITY CONTROL # #
# using nf-core/taxprofiler v1.2.0

nextflow run nf-core/taxprofiler -r 1.2.0  -profile docker --input sample_sheet.csv --databases databases.csv --outdir Cmic_taxpro --run_kraken2  --run_diamond  --run_krona  --perform_shortread_qc --perform_shortread_hostremoval False   --perform_longread_qc   --perform_longread_hostremoval False --save_analysis_ready_fastqs
