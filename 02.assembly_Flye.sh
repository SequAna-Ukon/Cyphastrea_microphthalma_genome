#!/bin/bash
# Script for genome assembly using flye v. 2.9.5


# --------------------------------------
# # ENVIRONMENT & INSTALLATION # #
mamba create -n assembly_env bioconda::flye==2.9.5
mamba activate assembly_env

# -----------------------------------------
# ASSEMBLY # #
flye --nano-corr  20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01_CLEAN.fq.gz --genome-size 250m --threads 50 --out-dir Cmic_flye_corr --scaffold

# ------------------------------------------
# # QC OF THE ASSEMBLY # #
mamba activate qc_env

mamba install -c bioconda gfastats
mamba install -c bioconda busco

gfastats /PATH/TO/Cmic_assembly_flye.fasta

busco -i /PATH/TO/Cmic_assembly_flye.fasta -m geno -l eukaryota_odb10  -o busco_euk
busco -i /PATH/TO/Cmic_assembly_flye.fasta -m geno -l metazoa_odb10  -o busco_meta
busco -i /PATH/TO/Cmic_assembly_flye.fasta -m geno -l bacteria_odb10  -o busco_bact

