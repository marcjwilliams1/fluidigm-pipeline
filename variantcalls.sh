#!/bin/sh
#$ -cwd
#$ -V
#$ -e errorfiles
#$ -o outfiles
#$ -l h_vmem=8G

directory=$1
targetregions=$2

Rscript deepsnv.R ${directory} ${targetregions}

./filterdeepsnv.sh ${directory}
