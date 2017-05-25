#!/bin/sh
#$ -cwd
#$ -V
#$ -e errorfiles
#$ -o outfiles

results_dir=$1
name=$2

chmod 755 plot_coverage.sh
Rscript plot_coverage.sh $results_dir

chmod 755 analysepicardmetrics.sh
Rscript analysepicardmetrics.R $results_dir $name
