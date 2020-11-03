source("renv/activate.R")

sink(snakemake@log[[1]])
info <- Sys.info();

message(stringr::str_c(names(info), " : ", info, "\n"))
print(stringr::str_c(names(info), " : ", info, "\n"))

message("loading packages")
library(magrittr)
library(phyloseq)
library(qs)

message("reading phyloseq from ", snakemake@input[["phyloseq"]])
ps <- qs::qread(snakemake@input[["phyloseq"]])


message("computing diversity")
print("computing diversity")
diversity <- microbiome::alpha(ps) %>%
  tibble::as_tibble(rownames = "sample")

message("saving alpha diversity in ", snakemake@output[["alpha"]])
diversity %>% qs::qsave(snakemake@output[["alpha"]])
