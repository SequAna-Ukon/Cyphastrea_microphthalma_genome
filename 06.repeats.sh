#!/bin/bash

conda activate repeats
conda install -c bioconda -c conda-forge barrnap
conda install -c bioconda vsearch

# ------------------------- REPEAT IDENTIFICATION & MASKING ---------------

assembly="/PATH/TO/Cmic_final.fasta"

# # Pull docker images for RepeatModeler and EDTA # #
docker pull dfam/tetools:latest
docker pull quay.io/biocontainers/edta:2.2.2--hdfd78af_1

############## REPEAT MODELER ###############

docker run -v $PWD:/in -w /in dfam/tetools:latest BuildDatabase -name Cmic_genome $assembly
docker run -v $PWD:/in -w /in dfam/tetools:latest RepeatModeler -database Cmic_genome -LTRStruct -threads 40

################## EDTA #####################
docker run -v $PWD:/in -w /in quay.io/biocontainers/edta:2.2.2--hdfd78af_1 EDTA.pl --genome $assembly --sensitive 1 --anno 1 -t 32 --overwrite 1 --force 1

############ COMBINE REPEAT MODELER & EDTA ############### 

cat *-families.fa *.mod.EDTA.TElib.fa > Cmic_RE_DB.fa

# addtional 5 Reference available Merulinidae genomes in NCBI were used to compile the RE database
# #  Remove duplicates from repeats db # #
vsearch --derep_fulllength Cmic_RE_DB.fa --output Cmic_RE_DB_dedup.fasta

# # Get Repeat distribution # #
grep '>' Cmic_RE_DB_dedup.fasta | sed -r 's/.+#//' | sed -r 's/\s+.+//' | sort | uniq -c

# # Repeats masking using Repeats DB from previous step # #
docker run -v $PWD:/in -w /in dfam/tetools:latest RepeatMasker $assembly -lib Cmic_RE_DB_dedup.fasta -pa 8 -norna -xsmall

# The full report of the repeats percentage will be outputted after masking in assembly.fasta.tbl file
