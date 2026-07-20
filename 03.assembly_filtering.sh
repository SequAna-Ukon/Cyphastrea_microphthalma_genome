#!/bin/bash

# conda environment
conda activate btk

# make metadata.yml
ln -s /path/to/meta_cmic_flye.yaml .

# creating hits file
cd /path/to/databases/ncbi/

blastn -db ./nt/nt \
-query /PATH/TO/Cmic_assembly_flye.fasta \
-outfmt "6 qseqid staxids bitscore std" \
-max_target_seqs 10 \
-max_hsps 1 \
-evalue 1e-25 \
-num_threads 30 \
-out /path/to/btk/blastn_cmic.out

cd /path/to/databases/uniprot/

diamond blastx --query /PATH/TO/Cmic_assembly_flye.fasta \
--db reference_proteomes.dmnd \
--outfmt 6 qseqid staxids bitscore qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
--sensitive \
--max-target-seqs 1 \
--evalue 1e-25 \
--tmpdir /dev/shm \
--threads 30 > /path/to/btk/cmic_diamond.blastx.out

# create coverage file

minimap2 -ax sr -t 32 /PATH/TO/Cmic_assembly_flye.fasta \
/path/to/raw_reads/Cmic_reads_porechopped.fastq.gz | samtools sort -@32 -O BAM -o cmic_btk_cov.bam -

# Create a BlobDir from a fasta assembly file
blobtools create --fasta /PATH/TO/Cmic_assembly_flye.fasta --meta meta_cmic.yaml --taxid 570133 --taxdump /path/to/btk/taxdump/ btk

# add hits to BlobDir
blobtools add --hits cmic_diamond.blastx.out --hits blastn_cmic.out --taxrule bestsumorder --taxdump /path/to/btk/taxdump/ btk

# add coverage to BlobDir
blobtools add --cov cmic_btk_cov.bam btk

# add data from busco results to the BlobDir
blobtools add --busco /path/to/busco/full_table.tsv btk

blobtools view --remote btk

# FILTER ASSEMBLY

# If your interactive session includes a selection, details of the selection are not captured in the url query string. Instead the selection can be exported as a JSON format list file that includes details of any filter parameters
# and a list of selected contigs. This file can be used to filter the assembly with the --json option.

blobtools filter --json /path/to/exported_list_file.json --fasta /PATH/TO/Cmic_assembly_flye.fasta btk
