#!/usr/local/bin/Rscript

"Plot quality profiles

Usage:
  plot_quality_profiles.R <plot_file> --end1=<end1> --end2=<end2> [--logfile=<logfile>]
  plot_quality_profiles.R (-h|--help)
  plot_quality_profiles.R --version" -> doc

library(docopt)

my_args <- commandArgs(trailingOnly = TRUE)

if (length(my_args) == 0) {
  my_args <- c("qc_profile.png", "--end1=end1.fastq.gz",
    "--end2=end2.fastq.gz")
}

arguments <- docopt(doc, args = my_args,
  version = "plot_quality_profiles V1")
print(arguments)

if (is.null(arguments$logfile)) {
  arguments$logfile <- "./plot_quality_profiles.log"
}

log_file <- file(arguments$logfile, open = "wt")
sink(log_file)
sink(log_file, type = "message")

message("system info")
print(Sys.info())

message("arguments")
print(arguments)

stopifnot(file.exists(arguments$end1), file.exists(arguments$end2))

message("loading R packages")
library(dada2, quietly = TRUE)
library(ggplot2, quietly = TRUE)
library(purrr, quietly = TRUE)
library(cowplot, quietly = TRUE)

message("making plots")

plot_fun <- purrr::safely(dada2::plotQualityProfile)

r1_plot <- plot_fun(arguments$end1)
r2_plot <- plot_fun(arguments$end2)

if (is.null(r1_plot$error)) {
  r1_plot <- r1_plot$result
} else {
  message(r1_plot$error)
  r1_plot <- ggplot()
}

if (is.null(r2_plot$error)) {
  r2_plot <- r2_plot$result
} else {
  message(r2_plot$error)
  r2_plot <- ggplot()
}

message("saving plots")
final_plot <- cowplot::plot_grid(r1_plot, r2_plot, nrow = 1)

ggsave(filename = arguments$plot_file, final_plot, ggsave, width = 8,
  height = 4, units = "in")

sink(type = "message")
sink()
