#!/usr/local/bin/Rscript

#' Wrapper around `dada2::filterAndTrim function
#' For details on the meaning of the parameters use
#' R -e `?dada2::filterAndTrim`

"Filter and trim

Usage:
filter_and_trim.R [<filter_end1> <filter_end2> <summary_file>] [<sample_name> --end1=<end1> --end2=<end2>] [--log=<logfile> --batch=<batch> --config=<cfile> --cores=<cores>]
filter_and_trim.R (-h|--help)
filter_and_trim.R --version

Options:
-h --help    show this screen
--end1=<end1>    name of the R1 end fastq.gz file
--end2=<end2>    name of the R2 end fastq.gz file
--log=<logfile>    name of the log file [default: filter_and_trim.log]
--batch=<batch>    name of the batch if any to get the filter and trim parameters
--config=<cfile>    name of the yaml file with the parameters [default: ./config/config.yaml]
--cores=<cores>    number of CPUs for parallel processing [default: 4]" -> doc

library(docopt)

my_args <- commandArgs(trailingOnly = TRUE)

arguments <- docopt::docopt(doc, args = my_args, version = "filter_and_trim V1")
arguments$cores <- as.numeric(arguments$cores)


log_file <- file(arguments$log, open = "wt")
sink(log_file)
sink(log_file, type = "message")

print(arguments)

info <- Sys.info();

message("loading dada2")
library(magrittr)
library(dada2)
library(qs)
library(yaml)

stopifnot(file.exists(arguments$config),
  file.exists(arguments$end1), file.exists(arguments$end2))

print(stringr::str_c(names(info), " : ", info, "\n"))
config <- yaml::read_yaml(arguments$config)$filter_and_trim
print(config)

if (arguments$batch %in% names(config)) config <- config[[arguments$batch]]


track.filt <- dada2::filterAndTrim(
  arguments$end1, arguments$filter_end1,
  arguments$end2, arguments$filter_end2,
  truncQ =    as.numeric(config[["truncQ"]]),
  truncLen =  as.numeric(config[["truncLen"]]),
  trimLeft =  as.numeric(config[["trimLeft"]]),
  trimRight = as.numeric(config[["trimRight"]]),
  maxLen =    as.numeric(config[["maxLen"]]),
  minLen =    as.numeric(config[["minLen"]]),
  maxN =      as.numeric(config[["maxN"]]),
  minQ =      as.numeric(config[["minQ"]]),
  maxEE =     as.numeric(config[["maxEE"]]),
  rm.phix = TRUE,
  compress = TRUE,
  multithread = arguments$cores)

row.names(track.filt) <- arguments$sample_name
colnames(track.filt) <- c("raw", "filtered")

track.filt %>%
  as.data.frame() %>%
  tibble::as_tibble(rownames = "samples") %>%
readr::write_tsv(arguments$summary_file)
