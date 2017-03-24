library(tidyverse)
library(stringr)

files <- list.files("clean/", pattern = "dbsnp")
dfall <- data.frame()

for (file in files){
  print(file)
  
  patientid <- str_split(file, "[.bam]")[[1]][1]
  cryptid <- str_split(file, "[.bam]")[[1]][2]
  sname <- paste(patientid, cryptid, sep = ".")
  root <- str_split(file, ".dbsnp")[[1]][1]
  tissuetype <- str_sub(patientid, -1)
  
  exonic <- read.delim(paste("clean/", root, ".exonic.txt", sep = ""), header = T, colClasses = "character") %>%
    mutate(mutid = paste(chr, start, end, ref, var, sep = "")) %>%
    mutate(depthnormal = as.numeric(cov.ctrl.fw) + as.numeric(cov.ctrl.bw)) %>%
    mutate(depthtumour = as.numeric(cov.tst.fw) + as.numeric(cov.tst.bw)) %>%
    mutate(readcountnormal = as.numeric(n.ctrl.fw )+ as.numeric(n.ctrl.bw)) %>%
    mutate(readcounttumour = as.numeric(n.tst.fw) + as.numeric(n.tst.bw))
  allvariants <- read.delim(paste("clean/", root, ".all.txt", sep = ""), header = T, colClasses = "character") %>%
    mutate(mutid = paste(chr, start, end, ref, var, sep = "")) %>% dplyr::select(region, gene, mutid) %>%
    dplyr::rename(genename = gene)
  dbsnp <- read.delim(paste("clean/", root, ".dbsnp.txt", sep = ""), header = T, colClasses = "character") %>%
    mutate(mutid = paste(chr, start, end, ref, var, sep = "")) %>% dplyr::select(dbsnp, rsnumber, mutid)
  cosmic <- read.delim(paste("clean/", root, ".cosmic.txt", sep = ""), header = T, colClasses = "character") %>%
    mutate(mutid = paste(chr, start, end, ref, var, sep = "")) %>% dplyr::select(cosmic, cosmicid, mutid)
  
  genecov <- read.delim(paste("coverage/", patientid, ".", cryptid, ".coverage.sample_gene_summary", sep = "")) %>%
    select(Gene, contains("above"))
  names(genecov) <- c("Gene", "above100")
  genecov <- genecov %>% spread(Gene, above100)
  genecov$meangenecov <- rowMeans(genecov)
  genecov <- as.data.frame(lapply(genecov, rep, length(exonic$line)))
  
  totcov <- read.delim(paste("coverage/", patientid, ".", cryptid, ".coverage.sample_summary", sep=""))
  
  df <- left_join(exonic, dbsnp, by = "mutid") %>%
    full_join(allvariants, by  = "mutid")
  df <- left_join(df, cosmic, by = "mutid")
  df <- cbind(df, genecov)
  
  if (length(df$line) == 0){
    next
  }
  
  df$meancov <- totcov$mean[1]
  df$sname <- sname
  df$patientid <- patientid
  df$cryptid <- cryptid
  df$tissuetype <- tissuetype
  
  df <- dplyr::select(df, sname, patientid, cryptid, 
                      tissuetype, genename, function., gene, dbsnp, rsnumber,
                      cosmic, cosmicid,
                      chr, start, end, ref, var, freq.var, 
                      readcounttumour, depthtumour,
                      readcountnormal, depthnormal, mutid,
                      APC, BRAF, CTNNB1,FBXW7, KIT, KRAS, MSH2, NRAS,
                      PIK3CA, POLE, REEP5, RNF43, SMAD4, SOX9,TCF7L2, TP53, meangenecov, meancov) %>%
    mutate(dbsnp = ifelse(is.na(dbsnp), "no", "yes")) %>%
    mutate(cosmic = ifelse(is.na(cosmic), "no", "yes")) %>%
    dplyr::rename(VAF = freq.var) %>%
    mutate(VAF = as.numeric(VAF)) %>%
    mutate(VAFcontrol = readcountnormal / depthnormal) %>%
    mutate(tissuetype = ifelse(tissuetype == "I", "IBD", "Normal"))
  dfall <- rbind(df, dfall)
}

dfall <- dfall %>%
  mutate(VAFtest = VAF) %>%
  select(-VAF)

dfall <- dfall %>% dplyr::rename(mutationfunction = function.) %>%
  filter(readcounttumour > 5, depthtumour > 100, depthnormal > 100, VAFcontrol < 0.05, VAF > 0.05)

#dfall %>%
#  filter(VAFr != "0.5" & VAFr != "1" & mutationfunction != "synonymous SNV") %>%
#  write_csv("filteredvariantcalls/filteredmutations.csv")

dfall %>%
  write_csv("filteredvariantcalls/march2017_fluidigm_allmutations.csv")

dfall %>% filter(mutationfunction != "synonymous SNV") %>% 
  write_csv("filteredvariantcalls/march2017_fluidigm_allmutations_filt.csv")

  
  
  
  