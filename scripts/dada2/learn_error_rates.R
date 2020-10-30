
# dada2::learnErrors wrap for condor based pipeline
#
# Assumes that we have paired end files, therefore, we learn two error rates
# matrices, i.e. one for each end.
#


sink(snakemake@log[[1]])

info <- Sys.info();
message(stringr::str_c(names(info), " : ", info, "\n"))
print(stringr::str_c(names(info), " : ", info, "\n"))

message("loading packages")
library(dada2)
library(ggplot2)
library(qs)


err_fwd <- dada2::learnErrors(
  snakemake@input[["R1"]], nbases = snakemake@config[["learn_nbases"]],
  multithread = snakemake@threads, randomize = TRUE)
err_bwd <- dada2::learnErrors(
  snakemake@input[["R2"]], nbases = snakemake@config[["learn_nbases"]],
  multithread = snakemake@threads, randomize = TRUE)

qs::qsave(err_fwd, file = snakemake@output[["errR1"]])
qs::qsave(err_bwd, file = snakemake@output[["errR2"]])

err_fwd_plot <- dada2::plotErrors(err_fwd, nominalQ = TRUE)
err_bwd_plot <- dada2::plotErrors(err_bwd, nominalQ = TRUE)

ggplot2::ggsave(
  filename = snakemake@output[["plotErr1"]],
  plot = err_fwd_plot,
  width = 20,
  height = 20,
  units = "cm")

ggplot2::ggsave(
  filename = snakemake@output[["plotErr2"]],
  plot = err_bwd_plot,
  width = 20,
  height = 20,
  units = "cm")