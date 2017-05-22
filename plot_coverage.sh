#!/share/apps/R/3.3.1/bin/Rscript

#library(colorspace)
library(ggplot2)
library(scales)

#colpal<-rainbow_hcl(10, start = -130, end = 600)

removeExtraLine <- function(x) {
  x[,2:length(x)]
}

createInitialDataset <- function(x, sampleName) {

  extraLineRemoved <- t(removeExtraLine(x))
  df <- data.frame(extraLineRemoved, rep(sampleName))
  colnames(df) <- c("coverage","proportion_coverage","sample")
  df$coverage <- sapply(df$coverage, function(x) sub("gte_", "", x))
  df$coverage <- as.numeric(df$coverage)
  df$proportion_coverage <- as.numeric(as.character(df$proportion_coverage))
  df$pct <- df$proportion_coverage*100

  return(df)
}


args = commandArgs(trailingOnly=TRUE)

results_dir <- args[1]
filedir <- paste(results_dir, "/coverage", sep = "")
plotdir<-paste(filedir, "/plots", sep = "")

props=list.files(filedir,pattern="proportions")

stats=list.files(filedir,pattern="sample_summary")

dfall <- data.frame()
meandepth <- c()

for (i in 1:length(props)){

  dfstats<-read.table(paste(filedir,"/",stats[i],sep=""),header=T,nrows=1)

  sample_1<-read.delim(paste(filedir,"/",props[i],sep=""),header=F)
  sample_list<-list(sample_1)
  df<-createInitialDataset(sample_list[[1]], sample_list[[1]][[2,1]])

g <- ggplot(df, aes(x = coverage, y = pct)) + geom_area() +
     xlab("Depth of coverage") +
     ylab("% of Target") +
     ggtitle(paste("mean depth = ",dfstats$mean,sep="")) +
     theme_bw() +
     theme(text = element_text(size=20))
 ggsave(filename=paste(plotdir,"/",props[i],".coverage",".pdf",sep=""),
 plot=g)

  meandepth <- c(meandepth, dfstats$mean)
  df$meanD <- dfstats$mean

  dfall <- rbind(dfall, df)


}


dfall$samplename <- paste(dfall$sample, "\n", dfall$meanD, sep = "")

g <- ggplot(dfall, aes(x = coverage, y = pct)) + geom_area() +
   xlab("Depth of coverage") +
   #xlim(c(0, 10000)) +
   ylab("% of Target") +
   theme_bw() +
   scale_x_continuous(labels=comma, limits = c(0, 10000)) +
   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
   facet_wrap(~samplename)

ggsave(filename=paste(plotdir,"/allcoverageplots.pdf",sep=""),
plot=g,
width = 15, height = 10)
