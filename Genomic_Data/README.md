# Genomic Data

This directory contains the final *Cyphastrea microphthalma* (Cmic) isolate **UAE_SA_Cmic_10** genome assembly and genome annotation, together with assembly and annotation quality assessment results.

## Directory structure

### assembly/

| File | Description |
|------|-------------|
| `Cmic_V1.fna.gz` | Final genome assembly in FASTA format. |

### annotation/

| File | Description |
|------|-------------|
| `Cmic_V1.gff.gz` | Structural genome annotation in GFF3 format, including gene models and genomic features. |
| `Cmic_V1_CDS.fa.gz` | Coding DNA sequences (CDS) extracted from annotated genes. |
| `Cmic_V1.faa.gz` | Predicted protein sequences translated from annotated protein-coding genes. |
| `Cmic_V1_RE.gff.gz` | Genomic coordinates of annotated repetitive elements. |

### BUSCO/

BUSCO quality assessments are provided separately for the genome assembly and the genome annotation.

#### assembly/

| File | Description |
|------|-------------|
| `short_summary.txt` | Summary of BUSCO completeness scores for the genome assembly. |
| `full_table.tsv` | Complete list of BUSCO genes and their classification (Complete, Fragmented, or Missing). |
| `missing_busco_list.tsv` | List of BUSCO genes not detected in the genome assembly. |

#### annotation/

| File | Description |
|------|-------------|
| `short_summary.txt` | Summary of BUSCO completeness scores for the predicted gene set. |
| `full_table.tsv` | Complete list of BUSCO genes identified in the annotated proteins and their classification. |
| `missing_busco_list.tsv` | List of BUSCO genes not detected in the annotated protein set. |


## License

These files are distributed under the license included in this repository.
