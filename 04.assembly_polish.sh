#!/bin/bash
# polish Cmic_assembly_flye.fasta using Pilon & Medaka

##############
# # MEDAKA (using long-reads) # #
##############

conda activate polish
conda install -c conda-forge -c bioconda medaka pilon

minimap2 -ax map-ont -t 50 Cmic_flye_corr/assembly.fasta 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01_CLEAN.fq.gz > aligned_reads.sam
samtools view -@ 50 -Sb aligned_reads.sam | samtools sort -@ 50 -o Cmic.lreads.bam
samtools index Cmic.lreads.bam
medaka_consensus -i Cmic.lreads.bam -d Cmic_flye_corr/assembly.fasta -o medaka_output -m r941_min_hac_g507 -t 50

#############
# # Pilon # #
# v 1.24 (using short-reads)
#############

bowtie2-build  --threads 50 medaka_output/consensus.fasta Cmic_meda
bowtie2 -p 50 -x Cmic_meda -1 Cmic_taxpro/analysis_ready_fastqs/Cmic_Illu_Cmic_Illu_1.fastp.fastq.gz -2 Cmic_taxpro/analysis_ready_fastqs/Cmic_Illu_Cmic_Illu_2.fastp.fastq.gz -S aligned_Sreads.sam
samtools view -@50 -S -b aligned_Sreads.sam > aligned_Sreads.bam
samtools sort -@50 -o sorted_Sreads.bam aligned_Sreads.bam
samtools index sorted_Sreads.bam
java -Xmx50G -jar pilon-1.24.jar --threads 16 --genome medaka_output/consensus.fasta  --frags sorted_Sreads.bam --output polished_assembly

######################
# # scaffolding # #
######################

docker run -v `pwd`/reads:/reads:rw -it cgenomics/redundans:latest /root/src/redundans/redundans.py -v -i reads/*_{1,2}.fastp.fastq.gz -f reads/polished_assembly.fasta -o reads/Cmic_redu -l reads/Cmic_ont_clean.fq.gz --minimap2scaffold  -t 50 --runmerqury

######################
# # CLEAN ASSEMBLY # #
######################

conda activate anno_env
funannotate clean -i scaffolds.reduced.fa -m 200 -o Cmic.clean.fna
funannotate sort -i Cmic.clean.fna -o Cmic_final.fasta -b Cmic

###########################################
# final assembly: Cmic_final.fasta #
###########################################

#############
# # BUSCO # #
#############

busco -i Cmic_final.fastaa -m geno -l eukaryota_odb10 -c 30 -o busco_euk
busco -i Cmic_final.fasta -m geno -l metazoa_odb10 -c 30 -o busco_meta
busco -i Cmic_final.fasta -m geno -l bacteria_odb10 -c 30 -o busco_bact
