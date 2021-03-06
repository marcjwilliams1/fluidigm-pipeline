#!/bin/sh

results_dir=/data/BCI-EvoCa/marc/nikolina/run3
target=/data/BCI-EvoCa/marc/refs/fluidigm/targetregions.bed
baits=$target
filelist=fastqfiles.txt

targetpicard=/data/BCI-EvoCa/marc/refs/fluidigm/targetregions.interval.list
baitspicard=$targetpicard
refseq=/data/BCI-EvoCa/marc/refs/fluidigm/fluidigmrefseq.txt

mkdir errorfiles
mkdir outfiles
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
mkdir -p ${results_dir}/info/qsdistribution/
mkdir -p ${results_dir}/finalresults/

numsamples=42
name="nikolinarun3june2017"

qsub -t 1-${numsamples} -l h_rt=1:0:0 -l h_vmem=8G -N fastq2bam fastq2processedbam.sh $filelist $results_dir $target $refseq

qsub -t 1-${numsamples} -hold_jid fastq2bam -N picardmetrics -l h_rt=1:0:0 -l h_vmem=4G picardmetrics.sh $filelist $results_dir $targetpicard $baitspicard

qsub -hold_jid fastq2bam -N variantcalls -l h_vmem=8G -l h_rt=10:0:0 variantcalls.sh $results_dir $target

qsub -hold_jid picardmetrics -N clean -l h_rt=10:0:0 -l h_vmem=4G clean.sh $results_dir $name
