
source("renv/activate.R")
message("loading dada2")
library(dada2)
library(ggplot2)
library(future)
library(furrr)

message("making plots")

future::plan(future::multiprocess(workers = snakemake@threads / 2))

plots <- furrr::future_map(snakemake@input, dada2::plotQualityProfile)

message("saving plots")
out <- purrr::map2(
  snakemake@output,
  plots, ggsave, width = 5, height = 4, units = "in")
