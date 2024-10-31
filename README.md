# Cmic_genome
Cyphastrea microphthalma  Genome assembly and annotation using ONT and Illumina reads
- no genome for it yet -- but likely 400-600 Mb

## Clean up/filter: 
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

### 2. Hybrid approach in two-step
flye
flye --nano-hq  Aip_clean.fq.gz --genome-size 275m --out-dir aip_flye_hq --scaffold
flye --nano-corr  Aip_clean.fq.gz --genome-size 275m --out-dir aip_flye_corr --scaffold
flye --nano-raw  Aip_clean.fq.gz --genome-size 275m --out-dir aip_flye_raw --scaffold
