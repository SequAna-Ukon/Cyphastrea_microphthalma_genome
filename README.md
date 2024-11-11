# Cmic_genome
Cyphastrea microphthalma  Genome assembly and annotation using ONT and Illumina reads
- no genome for it yet -- but likely 400-600 Mb

## Clean up/filter
- trimmomatic for short reads

````bash
trimmomatic PE -threads 50 -phred33 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-Illumina_QCVTS273D5_QCVTS279DJ_21045b240_R1.fastq.gz 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-Illumina_QCVTS273D5_QCVTS279DJ_21045b240_R2.fastq.gz -baseout Cmic_Illu.fq.gz ILLUMINACLIP:adapt.fa:2:30:10
````
- porechop for ONT (Done by Rach)
````bash
porechop -i 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01.fastq.gz -o 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01_CLEAN.fq --discard_middle
````

## QC and Taxonomy Profiling reads

- using nf-core/taxprofiler v1.2.0

```bash
nextflow run nf-core/taxprofiler -r 1.2.0  -profile docker --input sample_sheet.csv --databases ../Victor_1215/databases.csv --outdir Cmic_taxpro --run_kraken2  --run_diamond  --run_krona  --perform_shortread_qc --perform_shortread_hostremoval False   --perform_longread_qc   --perform_longread_hostremoval False --save_analysis_ready_fastqs
```
## Kmer profiling

- Using KMC and GenomeScope
````bash
mkdir tmp

ls *P.fq.gz > FILES
KMC/bin/kmc -k21 -m64 -ci1 -cs10000 @FILES kmcdb tmp
KMC/bin/kmc_tools transform kmcdb histogram kmcdb_k21.hist -cx10000
./genomescope2.0/genomescope.R -i kmcdb_k21.hist -o Cmic_GS -k 21
````
- Also, will use [smudgeplot](https://github.com/KamilSJaron/smudgeplot?tab=readme-ov-file)

````bash
FastK -v -t4 -k21 -M16 -T4 Cmic_Illu_[12]P.fq.gz -NFastK_Table
PloidyPlot -e12 -k -v -T4 -okmerpairs FastK_Table
smudgeplot.py plot -n 15 -t Cyphastrea_microphthalma -o Cmic_smudg kmerpairs_text.smu
````



## Assembly 

### 1. Hybrid approach in one-step
- SPAdes genome assembler v4.0.0
````bash
spades.py --careful -1 Cmic_taxpro/analysis_ready_fastqs/Cmic_Illu_Cmic_Illu_1.fastp.fastq.gz -2 Cmic_taxpro/analysis_ready_fastqs/Cmic_Illu_Cmic_Illu_2.fastp.fastq.gz --nanopore 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01_CLEAN.fq.gz -t 50 -m 100 -o SPAd_Cmic
````
- SPAdes produced ~3 million of contigs then switched to MaSuRCA.

- MaSuRCA v4.1.2

````bash
masurca -i Cmic_taxpro/analysis_ready_fastqs/Cmic_Illu_Cmic_Illu_1.fastp.fastq.gz, Cmic_taxpro/analysis_ready_fastqs/Cmic_Illu_Cmic_Illu_2.fastp.fastq.gz -r 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01_CLEAN.fq.gz  -t 50 -o assemble_masu.sh
````

### 2. Hybrid approach in two-step

#### long-reads assembly

- flye v. 2.9.5

````bash
flye --nano-hq  20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01_CLEAN.fq.gz --genome-size 250m --threads 50 --out-dir Cmic_flye_hq --scaffold
flye --nano-corr  20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01_CLEAN.fq.gz --genome-size 250m --threads 50 --out-dir Cmic_flye_corr --scaffold
flye --nano-raw  20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01_CLEAN.fq.gz --genome-size 250m --threads 50 --out-dir Cmic_flye_raw --scaffold
````

- Cmic_flye_corr shows the best assembly stats, will proceed with it.

#### Polishing


- Medaka (using long-reads)

````bash
minimap2 -ax map-ont -t 50 Cmic_flye_corr/assembly.fasta 20220603_UAE_SA_Cmic_10_34.1_1080_gDNA_host_WGS-ONT_QCVTS273D5_QCVTS287DA_21045LRb240_01_CLEAN.fq.gz > aligned_reads.sam
samtools view -@ 50 -Sb aligned_reads.sam | samtools sort -@ 50 -o Cmic.lreads.bam
samtools index Cmic.lreads.bam
medaka_consensus -i Cmic.lreads.bam -d Cmic_flye_corr/assembly.fasta -o medaka_output -m r941_min_hac_g507 -t 50
````


- Pilon (using short-reads)
  
````bash
bowtie2-build  --threads 50 medaka_output/consensus.fasta Cmic_meda
bowtie2 -p 50 -x Cmic_meda -1 Cmic_taxpro/analysis_ready_fastqs/Cmic_Illu_Cmic_Illu_1.fastp.fastq.gz -2 Cmic_taxpro/analysis_ready_fastqs/Cmic_Illu_Cmic_Illu_2.fastp.fastq.gz -S aligned_Sreads.sam
samtools view -@50 -S -b aligned_Sreads.sam > aligned_Sreads.bam
samtools sort -@50 -o sorted_Sreads.bam aligned_Sreads.bam
samtools index sorted_Sreads.bam
java -Xmx16G -jar pilon-1.24.jar --genome medaka_output/consensus.fasta  --frags sorted_Sreads.bam --output polished_assembly
````

- Optional,

````bash
GapCloser -a polished_assembly.fasta -b soap.config -l 150 -o uni_gapclosed.fasta -t 8
````

## scaffolding

````bash
docker run -v `pwd`/reads:/reads:rw -it cgenomics/redundans:latest /root/src/redundans/redundans.py -v -i reads/*_?.fq.gz -f reads/spads_scaf.fasta -o spades_redu -t 50 --runmerqury
````
