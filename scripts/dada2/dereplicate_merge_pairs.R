# dada2::dada and dada2::mergePairs wrap
#
# This script is a bit more elaborated, because instead of wrapping only one
# dada2 method, this wraps the following:
#
# * dada2::derepFastq
# * dada2::dada
# * dada2::mergePairs
# * dada2::makeSequenceTable

info <- Sys.info();

sink(snakemake@log[[1]])


message(stringr::str_c(names(info), " : ", info, "\n"))
print(stringr::str_c(names(info), " : ", info, "\n"))

message("loading packages")
library(magrittr)
library(dada2)
library(qs)


filter_fwd <- snakemake@input[["R1"]]
filter_bwd <- snakemake@input[["R2"]]

sample.names <- snakemake@params[["samples"]]

message("loading error rates")
err_fwd <- qs::qread(snakemake@input[["errR1"]])
err_bwd <- qs::qread(snakemake@input[["errR2"]])

message("dereplicating filtered files")

dereplicate_merge <- function(sample, filtfwd, filtbwd, err_fwd, err_bwd,
  threads = 4, min_overlap = 12, max_mismatch = 0) {

  message("processing ", sample)
  derep_fwd <- dada2::derepFastq(filtfwd)
  dd_fwd <- dada2::dada(derep_fwd, err = err_fwd, multithread = threads)

  derep_bwd <- dada2::derepFastq(filtbwd)
  dd_bwd <- dada2::dada(derep_bwd, err = err_bwd, multithread = threads)

  merge <- dada2::mergePairs(dd_fwd, derep_fwd, dd_bwd, derep_bwd,
      minOverlap = min_overlap, maxMismatch = max_mismatch)

  out <- list(
    "dada_fwd" = dd_fwd,
    "dada_bwd" = dd_bwd,
    "merge" = merge)

  return(out)
}

derep_mergers <- purrr::pmap(
  list(sample.names, filter_fwd, filter_bwd),
  dereplicate_merge, err_fwd, err_bwd,
  threads = snakemake@threads,
  min_overlap = snakemake@config[["minOverlap"]],
  max_mismatch = snakemake@config[["maxMismatch"]])

mergers <- purrr::map(derep_mergers, "merge")
names(mergers) <- sample.names

dada_fwd <- purrr::map(derep_mergers, "dada_fwd")
dada_bwd <- purrr::map(derep_mergers, "dada_bwd")

message("creating sequence table")
seqtab <- dada2::makeSequenceTable(mergers)

qs::qsave(seqtab, snakemake@output[["seqtab"]])

message("summarizgin results")

## get N reads
get_nreads <- function(x) sum(dada2::getUniques(x))

track <- cbind(
    sapply(dada_fwd, get_nreads), sapply(mergers, get_nreads))
colnames(track) <- c( "denoised", "merged")

track %>%
  as.data.frame() %>%
  tibble::as_tibble(rownames = "samples") %>%
  readr::write_tsv(snakemake@output[["nreads"]])

message("Done! summary file at ", snakemake@output[["nreads"]])
