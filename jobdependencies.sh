#!/bin/sh

results_dir=/data/BCI-EvoCa/marc/normalcrypts/ibrahim/march2017
target=/data/BCI-EvoCa/marc/refs/fluidigm/targetregions.bed
baits=$target
filelist=fastqfiles.txt

mkdir -p ${results_dir}/processingbams
mkdir -p ${results_dir}/finalbams
mkdir -p ${results_dir}/coverage/plots
mkdir -p ${results_dir}/fastQC
mkdir -p ${results_dir}/bamQC
mkdir -p ${results_dir}/info/insertmetrics
mkdir -p ${results_dir}/info/alignmentmetrics/
mkdir -p ${results_dir}/info/insertmetrics
mkdir -p ${results_dir}/info/HS/
mkdir -p ${results_dir}/coveragepicard/
mkdir -p ${results_dir}/qsdistribution/
mkdir -p ${results_dir}/finalresults/

numsamples=100
name="manumay2017"

qsub -t 1-${numsamples} -l h_rt=10:0:0 -l h_vmem=12G -N fastq2bam  fastq2processedbam.sh $filelist $results_dir $target

qsub -hold_jid fastq2bam -N picardmetrics -l h_rt=10:0:0 -t 1-${numsamples} -l h_vmem=4G picardmetrics.sh $filelist $results_dir $target $baits

qsub -hold_jid fastq2bam -N variantcalls -l h_vmem=8G -l h_rt=20:0:0 variantcalls.sh $results_dir $target

qsub -hold_jid picardmetrics -N clean -l h_rt=10:0:0 -l h_vmem=4G clean.sh $results_dir $name
