#!/bin/bash

# Both structural and functional annotation has been done by GeneForge v2.1, A Nextflow Pipeline for Eukaryotic Gene Prediction and Functional Annotation  

mamba create -n annotation -c bioconda nextflow
mamba activate annotation

git clone https://github.com/SequAna-Ukon/Cyphastrea_microphthalma_genome.git

nextflow run GeneForge/main.nf \
  --mandatory_csv mandatory_Cmic.csv \
  --optional_csv optional_Cmic.csv \
  --mode both \
  --func_annotation

# mandatory_Cmic.csv
name,species,organism,busco_db,busco_db_fun,genome_masked,genome_unmasked,protein_evidence,genemark_dir
Cmic,Cyphastrea microphthalma,other,metazoa_odb10,metazoa,/path/to/Cmic_V1_new.masked,/path/to/Cmic_V1.fastaa,/path/to/Metazoa.faa,/path/to/genemark

#  optional_Cmic.csv

rnaseq_dir,funanno_DB,eggnog_DB,stranded,nanopore_mrna,pacbio_isoseq,gc_probability,func_tool_dir
/path/to/RNASeq,/path/to/funannotate_DB,/path/to/eggnog_DB,reverse,,,,/path/to/tools
