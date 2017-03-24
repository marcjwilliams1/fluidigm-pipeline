#!/bin/sh
#$ -cwd
#$ -V
#$ -l h_rt=4:0:0
#$ -e errorfiles
#$ -o outfiles
#$ -l h_vmem=8G

directory="/data/BCI-EvoCa/marc/normalcrypts/ibrahim/march2017"
targetregions="/data/BCI-EvoCa/marc/refs/fluidigm/targetregions.bed"

Rscript deepSNV.R ${directory} ${targetregions}

./filterdeepsnv.sh ${directory}
