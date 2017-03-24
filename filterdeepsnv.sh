#!/bin/sh

results_dir=$1

mkdir -p ${results_dir}/variantcalls/deepsnv/annotated/clean
mkdir -p ${results_dir}/variantcalls/deepsnv/annotated/annovar_output

files=$(ls ${results_dir}/variantcalls/deepsnv/raw/)

for i in $files
do

awk '{OFS="\t"} {print $1, $2, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16}' ${results_dir}/variantcalls/deepsnv/raw/$i > test.out

echo $'chr\tstart\tend\tref\tvar\tp.val\tfreq.var\tsigma2.freq.var\tn.tst.fw\tcov.tst.fw\tn.tst.bw\tcov.tst.bw\tn.ctrl.fw\tcov.ctrl.fw\tn.ctrl.bw\tcov.ctrl.bw\traw.p.val' |
cat  test.out | annotate_variation.pl --geneanno --outfile ${results_dir}/variantcalls/deepsnv/annotated/annovar_output/$i -buildver hg19 - /data/home/mpx155/bin/annovar/humandb

cat  test.out | annotate_variation.pl -filter -dbtype snp138 --outfile ${results_dir}/variantcalls/deepsnv/annotated/annovar_output/$i -buildver hg19 - /data/BCI-EvoCa/marc/refs/broad_bundle/humandb/

cat  test.out | annotate_variation.pl -filter -dbtype cosmic70 --outfile ${results_dir}/variantcalls/deepsnv/annotated/annovar_output/$i -buildver hg19 - /data/home/mpx155/bin/annovar/humandb

echo $'region\tgene\tchr\tstart\tend\tref\tvar\tp.val\tfreq.var\tsigma2.freq.var\tn.tst.fw\tcov.tst.fw\tn.tst.bw\tcov.tst.bw\tn.ctrl.fw\tcov.ctrl.fw\tn.ctrl.bw\tcov.ctrl.bw\traw.p.val' | cat - ${results_dir}/variantcalls/deepsnv/annotated/annovar_output/${i}.variant_function > ${results_dir}/variantcalls/deepsnv/annotated/clean/${i}.all.txt

echo $'line\tfunction\tgene\tchr\tstart\tend\tref\tvar\tp.val\tfreq.var\tsigma2.freq.var\tn.tst.fw\tcov.tst.fw\tn.tst.bw\tcov.tst.bw\tn.ctrl.fw\tcov.ctrl.fw\tn.ctrl.bw\tcov.ctrl.bw\traw.p.val' | cat - ${results_dir}/variantcalls/deepsnv/annotated/annovar_output/${i}.exonic_variant_function > ${results_dir}/variantcalls/deepsnv/annotated/clean/${i}.exonic.txt

echo $'dbsnp\trsnumber\tchr\tstart\tend\tref\tvar\tp.val\tfreq.var\tsigma2.freq.var\tn.tst.fw\tcov.tst.fw\tn.tst.bw\tcov.tst.bw\tn.ctrl.fw\tcov.ctrl.fw\tn.ctrl.bw\tcov.ctrl.bw\traw.p.val' | cat - ${results_dir}/variantcalls/deepsnv/annotated/annovar_output/${i}.hg19_snp138_dropped > ${results_dir}/variantcalls/deepsnv/annotated/clean/${i}.dbsnp.txt

echo $'cosmic\tcosmicid\tchr\tstart\tend\tref\tvar\tp.val\tfreq.var\tsigma2.freq.var\tn.tst.fw\tcov.tst.fw\tn.tst.bw\tcov.tst.bw\tn.ctrl.fw\tcov.ctrl.fw\tn.ctrl.bw\tcov.ctrl.bw\traw.p.val' | cat - ${results_dir}/variantcalls/deepsnv/annotated/annovar_output/${i}.hg19_cosmic70_dropped > ${results_dir}/variantcalls/deepsnv/annotated/clean/${i}.cosmic.txt

rm test.out


done
