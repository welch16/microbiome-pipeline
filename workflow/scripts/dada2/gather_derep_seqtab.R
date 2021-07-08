# dada2::dada and dada2::mergePairs wrap
#
# This script is a bit more elaborated, because instead of wrapping only one
# dada2 method, this wraps the following:
#
# * dada2::derepFastq
# * dada2::dada
# * dada2::mergePairs
# * dada2::makeSequenceTable
source("renv/activate.R")
info <- Sys.info();

sink(snakemake@log[[1]])


message(stringr::str_c(names(info), " : ", info, "\n"))
print(stringr::str_c(names(info), " : ", info, "\n"))

message("loading packages")
library(magrittr)
library(dada2)
library(qs)

derep_files <- snakemake@input[["derep"]]
sample.names <- snakemake@params[["samples"]]

derep_mergers <- purrr::map(derep_files, qs::qread)

mergers <- purrr::map(derep_mergers, "merge")
names(mergers) <- sample.names

dada_fwd <- purrr::map(derep_mergers, "dada_fwd")
dada_bwd <- purrr::map(derep_mergers, "dada_bwd")

message("creating sequence table")
seqtab <- dada2::makeSequenceTable(mergers)

qs::qsave(seqtab, snakemake@output[["seqtab"]])

message("summarizing results")

## get N reads
get_nreads <- function(x) sum(dada2::getUniques(x))

track <- cbind(
    sapply(dada_fwd, get_nreads), sapply(mergers, get_nreads))
colnames(track) <- c("denoised", "merged")

track %>%
  as.data.frame() %>%
  tibble::as_tibble(rownames = "samples") %>%
  readr::write_tsv(snakemake@output[["nreads"]])

message("Done! summary file at ", snakemake@output[["nreads"]])
