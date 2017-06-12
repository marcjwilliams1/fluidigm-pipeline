#!/bin/sh
#$ -cwd
#$ -V
#$ -e errorfiles
#$ -o outfiles

longLine="--------------------"

module unload gcc/4.8.2
module load gcc/6.3.0

##############################################################################
# Go from fastq files to BAM files.
# QC fatsqs using fatsqc, Map files using BWA, mark duplicates using picard
# calculate coverage statistica dn check BAM using bamQC
##############################################################################

#files list should have 5 columns, read1name, read2name, patient, samplename & tissuetype (T or N).
filelist=$1

##############################################################################
#set up directories and filenames
msg="Extract names from files"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
regionsfile=$3
results_dir=$2
refseq=$4


read1=$(awk -v var="$SGE_TASK_ID" 'NR ==var { OFS="\t";print $1}' $filelist)
read2=$(awk -v var="$SGE_TASK_ID" 'NR ==var { OFS="\t";print $2}' $filelist)
patient=$(awk -v var="$SGE_TASK_ID" 'NR ==var { OFS="\t";print $3}' $filelist)
samplename=$(awk -v var="$SGE_TASK_ID" 'NR ==var { OFS="\t";print $4}' $filelist)
tissuetype=$(awk -v var="$SGE_TASK_ID" 'NR ==var { OFS="\t";print $5}' $filelist)

readgroup="@RG\tID:${patient}.${samplename}\tLB:${patient}.${samplename}\tSM:${patient}.${samplename}\tPL:ILLUMINA"

##############################################################################
msg="run fastqc"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
#perform fastqc quality control
 /data/home/mpx155/bin/FastQC/fastqc ${results_dir}/fastq/${read1} ${results_dir}/fastq/${read2} --outdir=${results_dir}/fastQC/

##############################################################################

#add read group headers and align using bwa mem, pipe to samtools to convert to bam
 msg="map with BWA and pipe to samtools to convert to bam"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
 bwa mem -M -R ${readgroup} /data/BCI-EvoCa/marc/refs/hg19/ucsc.hg19.fasta \
 ${results_dir}/fastq/${read1} \
 ${results_dir}/fastq/${read2} | \
 samtools view -S -b - > ${results_dir}/processingbams/${patient}.${samplename}_unsort.bam

##############################################################################

#sort bam file an index using picard
 msg="sort bam with picard"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
 java -Xmx2G -jar $PICARD SortSam INPUT=${results_dir}/processingbams/${patient}.${samplename}_unsort.bam \
 OUTPUT=${results_dir}/processingbams/${patient}.${samplename}.bam \
 SORT_ORDER=coordinate CREATE_INDEX=true

##############################################################################

#remove unsorted bam file
 msg="remove unsorted bam"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
 rm ${results_dir}/processingbams/${patient}.${samplename}_unsort.bam

##############################################################################

#copy to final bams directory
 cp ${results_dir}/processingbams/${patient}.${samplename}.bam  ${results_dir}/finalbams/${patient}.${samplename}.bam
 cp ${results_dir}/processingbams/${patient}.${samplename}.bai ${results_dir}/finalbams/${patient}.${samplename}.bam.bai

##############################################################################

#check with bamqc
 msg="run bamqc"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
 /data/home/mpx155/bin/bamQC/BamQC/bin/bamqc -o ${results_dir}/bamQC/ ${results_dir}/finalbams/${patient}.${samplename}.bam

##############################################################################

#calculate coverage statistics
msg="run GATK coverage"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
java -jar -Xmx2G $GATK -T DepthOfCoverage \
-R /data/BCI-EvoCa/marc/refs/hg19/ucsc.hg19.fasta  \
-L ${regionsfile} \
-I ${results_dir}/finalbams/${patient}.${samplename}.bam \
-geneList:REFSEQ $refseq \
--start 1 \
--stop 100000 \
--nBins 500 \
--omitDepthOutputAtEachBase \
-ct 100 \
-o ${results_dir}/coverage/${patient}.${samplename}.coverage

msg="finished"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
