#!/bin/bash

gfastats Cmic_final.fasta -o gfa > Cmic.contigs.gfa


mamba activate assem_env
mamba install GetOrganelle

get_organelle_config.py --add  animal_mt

get_organelle_from_assembly.py -F animal_mt -g  /PATH/TO/Cmic.contigs.gfa -o animal_mt_out
