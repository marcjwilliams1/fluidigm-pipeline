#!/share/apps/R/3.3.1/bin/Rscript

library(dplyr)
args = commandArgs(trailingOnly=TRUE)

results_dir <- args[1]
name <- args[2]

# concetanate HStarget metrics
print("HS target metrics")
dir <- paste(results_dir, "/info/HS/", sep = "")
filename <- "HSmetrics"
files <- list.files(dir, pattern="metrics")
df <- data.frame()

for (file in files){

  print(file)

  metrics <- read.table(paste(dir, file, sep=""), sep="\t" , header=T)
  df1 <- data.frame(samplename = strsplit(file,"metrics")[[1]][1])
  df1 <- cbind(df1, metrics)

  df <- rbind(df, df1)

}

dfhs <- df
write.csv(df, paste(results_dir, "/info/", name, ".",filename, ".csv", sep=""), quote = FALSE, row.names = FALSE)

# concetanate alignment summary metrics
print("Alignment metrics")
dir <- paste(results_dir, "/info/alignmentmetrics/", sep = "")
filename <- "alignmentmetrics"
files <- list.files(dir, pattern="metrics")
df <- data.frame()

for (file in files){

  metrics <- read.table(paste(dir, file, sep=""), sep="\t" , header=T)
  df1 <- data.frame(samplename = strsplit(file,"metrics")[[1]][1])
  df1 <- cbind(df1, metrics)

  df <- rbind(df, df1)

}

dfas <- df
write.csv(df, paste(results_dir, "/info/", name, ".",filename, ".csv", sep=""), quote = FALSE, row.names = FALSE)


# concetanate insert size summary metrics
print("Insert metrics")
dir <- paste(results_dir, "/info/insertmetrics/", sep = "")
filename <- "insertsizemetrics"
files <- list.files(dir, pattern="metrics")
df <- data.frame()

for (file in files){

  metrics <- read.table(paste(dir, file, sep=""), sep="\t" , header=T)
  df1 <- data.frame(samplename = strsplit(file,"metrics")[[1]][1])
  df1 <- cbind(df1, metrics)

  df <- rbind(df, df1)

}

dfis <- df
write.csv(df, paste(results_dir, "/info/", name, ".",filename, ".csv", sep=""), quote = FALSE, row.names = FALSE)


dftemp <- left_join(dfis, dfas, by = "samplename")
dftemp <- left_join(dftemp, dfhs, by = "samplename")
write.csv(dftemp, paste(results_dir, "/info/", name, ".","allmetrics", ".csv", sep=""), quote = FALSE, row.names = FALSE)
