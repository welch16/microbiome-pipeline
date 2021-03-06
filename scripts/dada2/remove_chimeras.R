## merges different ASV tables, and removes chimeras
source("renv/activate.R")

sink(snakemake@log[[1]])

info <- Sys.info();
message(stringr::str_c(names(info), " : ", info, "\n"))
print(stringr::str_c(names(info), " : ", info, "\n"))

message("loading packages")
library(magrittr)
library(dada2)
library(qs)

seqtab_all <- qs::qread(snakemake@input[["seqtab"]])

# Remove chimeras
message("removing chimeras")
seqtab <- dada2::removeBimeraDenovo(
  seqtab_all,
  method = snakemake@config[["chimera_method"]],
  minSampleFraction = snakemake@config[["minSampleFraction"]],
  ignoreNNegatives = snakemake@config[["ignoreNNegatives"]],
  minFoldParentOverAbundance =
    snakemake@config[["minFoldParentOverAbundance"]],
  allowOneOf = snakemake@config[["allowOneOf"]],
  minOneOffParentDistance =
    snakemake@config[["minOneOffParentDistance"]],
  maxShift = snakemake@config[["maxShift"]],
  multithread = snakemake@threads)

qs::qsave(seqtab, snakemake@output[["asvs"]])

out <- tibble::tibble(samples = row.names(seqtab),
  nonchim = rowSums(seqtab))

out %>%
  readr::write_tsv(snakemake@output[["nreads"]])
