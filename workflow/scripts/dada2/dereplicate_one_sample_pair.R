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


filter_fwd <- snakemake@input[["R1"]]
filter_bwd <- snakemake@input[["R2"]]

message("loading error rates")
err_fwd <- qs::qread(snakemake@input[["errR1"]])
err_bwd <- qs::qread(snakemake@input[["errR2"]])

message("dereplicating filtered files")

dereplicate_merge <- function(filtfwd, filtbwd, err_fwd, err_bwd,
  min_overlap = 12, max_mismatch = 0) {

  derep_fwd <- dada2::derepFastq(filtfwd)
  dd_fwd <- dada2::dada(derep_fwd, err = err_fwd)

  derep_bwd <- dada2::derepFastq(filtbwd)
  dd_bwd <- dada2::dada(derep_bwd, err = err_bwd)

  merge <- dada2::mergePairs(dd_fwd, derep_fwd, dd_bwd, derep_bwd,
      minOverlap = min_overlap, maxMismatch = max_mismatch)

  out <- list(
    "dada_fwd" = dd_fwd,
    "dada_bwd" = dd_bwd,
    "merge" = merge)

  return(out)
}

merge <- dereplicate_merge(filter_fwd, filter_bwd, err_fwd, err_bwd,
  min_overlap = snakemake@config[["minOverlap"]],
  max_mismatch = snakemake@config[["maxMismatch"]])

qs::qsave(merge, snakemake@output[["merge"]])
