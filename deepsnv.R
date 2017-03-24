#!/share/apps/R/3.3.1/bin/Rscript
# runscript with Rscript deepSNV.R "/data/BCI-EvoCa/marc/normalcrypts/ibrahim/march2017/" 

args = commandArgs(trailingOnly=TRUE)
root <- args[1]
targetregions <- args[2]

library("deepSNV")
library(stringr)

bamfiledir <- paste(root, "/finalbams", sep = "")
variantcalldirectory <- paste(root, "/variantcalls/deepsnv/raw/", sep = "")

samples <- list.files(bamfiledir, pattern=".bam$")
controls <- samples[str_detect(samples, "BLOOD")]
samples <- samples[!str_detect(samples, "BLOOD")]

dfregions<-read.table(targetregions)
names(dfregions)<-c("chr","start","stop")

setwd(bamfiledir)

for (sample in samples) {

	patient <- strsplit(sample, "[.]")[[1]][1]

	if (patient == "363N"){
		control <- "363N.BLOOD-1.bam"
	} else {
		control <- str_subset(controls, patient)
	}

	samplebam <- paste(bamfiledir, "/", sample, sep = "")
	controlbam <- paste(bamfiledir, "/", control, sep = "")

	print(paste("processing bam "," ", sample, sep=""))

	calls <- deepSNV(test = samplebam, control = controlbam, regions = dfregions, q=30)

	SNVs<-summary(calls,sig.level = 0.05,
								adjust.method = "BH",
								value= "data.frame")
	SNVs<-SNVs[SNVs$freq.var > 0.05,]

	outfile<-paste(variantcalldirectory,
									sample, "_deepsnv_calls.txt",sep="")

	write.table(SNVs,
							file=outfile,
							row.names=FALSE,
							quote=FALSE)


}
