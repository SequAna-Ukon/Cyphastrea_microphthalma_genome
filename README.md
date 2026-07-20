# *Cyphastrea microphthalma* (Cmic) isolate UAE_SA_Cmic_10 reference genome assembly and annotation

This repository contains the scripts, genome assembly, annotation files, and figures used to generate the *Cyphastrea microphthalm* isolate UAE_SA_Cmic_10 reference genome described in:

## Open Access publication

**Alderdice et al. (2026).** *TThe genome sequence of the reef-building coral _Cyphastrea microphthalma_ from the Persian/Arabian Gulf* **GigaByte**. DOI: *TBD*

## Data availability

All raw data are available under NCBI BioProject **PRJNA1190223**:

https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1190223

The genome assembly has been deposited in DDBJ/ENA/GenBank under accession **JBMGOP000000000**:

https://www.ncbi.nlm.nih.gov/nuccore/JBMGOP000000000

## Scripts

### 00.reads_preprocessing.sh

Oxford Nanopore reads were trimmed using **PoreChop** while Illumina short reads trimmed using **trimmomatic** and quality assessed with **FastQC** and **NanoPlot**.

### 01.kmer_genome_size.sh
Kmer profiling was done using **GenomeScope 2.0** and **smudgeplot**.

### 02.assembly.sh

The genome was assembled using **Flye** and evaluated with **gfastats** and **BUSCO**.

### 03.assembly_filtering.sh

Contaminant sequences were identified and removed using **BlobToolKit**.

## 04.assembly_polish.sh
The assembled and filtered genome was polished using the short reads with Pilon and using the ONT reads with Medaka. The polished assembly was scaffolded using redundans. Finally, the resulted assembly was cleaned, contigs shorter than 200 bp were removed and headers were renamed and sorted using funannotate clean and funannotate sort.

### 05.mitogenome.sh

The mitochondrial genome was assembled using **GetOrganelle** and annotated with **MITOS2**.

### 06.repeats.sh

Repeats were identified using **EDTA** and **RepeatModeler**, then soft-masked with **RepeatMasker**.

### 07.structural$functional_annotation.sh

Structural annotation was performed with **funannotate**, using Illumina RNA-Seq data as transcript evidence. Additional tools included **tRNAscan-SE**, **STAR**, **BRAKER3**, **AGAT**, **GenomeTools**, and **gffread**. Functional annotation was performed using **InterProScan**, **EggNOG-mapper**, and **Phobius**, and integrated with **funannotate**. The final annotation was evaluated using **BUSCO**. The gene prediction and functional annotation were performed using the fully automated annotation pipeline **GeneForge v2.1**.

## Repository contents

### Genomic Data/

Contains the final genome assembly and annotation files:

- `assembly/` – genome assembly (FASTA)
- `annotation/` – GFF3, proteins, CDS, and repeat annotation
- `BUSCO/` – BUSCO assessment results

### figures/

Contains the files used to generate Figure 1 of the manuscript. See `figures/README.md` for details.

## License

This repository is distributed under the terms of the included `LICENSE` file.
