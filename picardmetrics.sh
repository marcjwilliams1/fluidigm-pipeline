#!/bin/sh
#$ -cwd
#$ -V
#$ -e errorfiles
#$ -o outfiles


filelist=$1

##############################################################################
#set up directories and filenames
msg="Extract names from files"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
regionsfile=$3
baits=$3
results_dir=$2


read1=$(awk -v var="$SGE_TASK_ID" 'NR ==var { OFS="\t";print $1}' $filelist)
read2=$(awk -v var="$SGE_TASK_ID" 'NR ==var { OFS="\t";print $2}' $filelist)
patient=$(awk -v var="$SGE_TASK_ID" 'NR ==var { OFS="\t";print $3}' $filelist)
samplename=$(awk -v var="$SGE_TASK_ID" 'NR ==var { OFS="\t";print $4}' $filelist)
tissuetype=$(awk -v var="$SGE_TASK_ID" 'NR ==var { OFS="\t";print $5}' $filelist)

java -Xmx2G -jar $PICARD CollectHsMetrics \
      I=${results_dir}/finalbams/${patient}.${samplename}.bam \
      O=${results_dir}/info/HS/${patient}.${samplename}.txt \
      R=$genome \
      BAIT_INTERVALS=${baits} \
      TARGET_INTERVALS=${regionsfile} \
      PER_TARGET_COVERAGE=${results_dir}/coveragepicard/${patient}.${samplename}.coverage.txt

grep -A2  "## METRICS" ${results_dir}/info/HS/${patient}.${samplename}.txt | tail -n +1 > ${results_dir}/info/HS/${patient}.${samplename}.metrics.txt

sed -e '1,/## HISTOGRAM/d' ${results_dir}/info/HS/${patient}.${samplename}.txt > ${results_dir}/info/HS/${patient}.${samplename}.histogram.txt

msg="Run picard insertsize metrics"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
java -Xmx2G -jar $PICARD CollectInsertSizeMetrics \
      INPUT=${results_dir}/finalbams/${patient}.${samplename}.bam \
      OUTPUT=${results_dir}/info/insertmetrics/${patient}.${samplename}.txt \
      H=${results_dir}/info/insertmetrics/${patient}.${samplename}.insert_size_histogram.pdf

grep -A2  "## METRICS" ${results_dir}/info/insertmetrics/${patient}.${samplename}.txt | tail -n +1 > ${results_dir}/info/insertmetrics/${patient}.${samplename}.metrics.txt

sed -e '1,/## HISTOGRAM/d' ${results_dir}/info/insertmetrics/${patient}.${samplename}.txt > ${results_dir}/info/insertmetrics/${patient}.${samplename}.histogram.txt

msg="Run picard CollectAlignmentSummaryMetrics"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
java -Xmx2G -jar $PICARD CollectAlignmentSummaryMetrics \
      R=$genome \
      ADAPTER_SEQUENCE=[CTGTCTCTTATA,TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG,GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG,AGATCGGAAGAGC,ACGCTCTTCCGATCT] \
      INPUT=${results_dir}/finalbams/${patient}.${samplename}.bam \
      OUTPUT=${results_dir}/info/alignmentmetrics/${patient}.${samplename}.txt

grep -A2  "## METRICS" ${results_dir}/info/alignmentmetrics/${patient}.${samplename}.txt | tail -n +1 > ${results_dir}/info/alignmentmetrics/${patient}.${samplename}.metrics.txt

msg="Run picard QualityScoreDistribution"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
java -Xmx2G -jar $PICARD QualityScoreDistribution \
      INPUT=${results_dir}/finalbams/${patient}.${samplename}.bam \
      OUTPUT=${results_dir}/info/qsdistribution/${patient}.${samplename}.qual_score_dist.txt \
      CHART=${results_dir}/info/qsdistribution/${patient}.${samplename}.qual_score_dist.pdf

sed -e '1,/## HISTOGRAM/d' ${results_dir}/info/qsdistribution/${patient}.${samplename}.qual_score_dist.txt > ${results_dir}/info/qsdistribution/${patient}.${samplename}.qshistogram.txt
