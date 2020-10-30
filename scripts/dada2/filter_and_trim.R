#  dada2::filterAndTrim wrapper
#
#  Assumes that we have paired end files,
#  and that the parameters for dada2 are stored in a json file.
#

sink(snakemake@log[[1]])
info <- Sys.info();

message("loading dada2")
library(magrittr)
library(dada2)
library(qs)


message(stringr::str_c(names(info), " : ", info, "\n"))
print(stringr::str_c(names(info), " : ", info, "\n"))
track.filt <- dada2::filterAndTrim(
  snakemake@input[["R1"]], snakemake@output[["R1"]],
  snakemake@input[["R2"]], snakemake@output[["R2"]],
  truncQ =    snakemake@config[["truncQ"]],
  truncLen =  snakemake@config[["truncLen"]],
  trimLeft =  snakemake@config[["trimLeft"]],
  trimRight = snakemake@config[["trimRight"]],
  maxLen =    snakemake@config[["maxLen"]],
  minLen =    snakemake@config[["minLen"]],
  maxN =      snakemake@config[["maxN"]],
  minQ =      snakemake@config[["minQ"]],
  maxEE =     snakemake@config[["maxEE"]],
  rm.phix = TRUE,
  compress = TRUE,
  multithread = TRUE)

row.names(track.filt) <- snakemake@params[["samples"]]
colnames(track.filt) <- c("raw", "filtered")

track.filt %>%
  as.data.frame() %>%
  tibble::as_tibble(rownames = "samples") %>%
readr::write_tsv(snakemake@output[["nreads"]])
