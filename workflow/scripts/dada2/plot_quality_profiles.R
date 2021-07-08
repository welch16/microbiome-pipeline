
source("renv/activate.R")
message("loading dada2")
library(dada2)
library(ggplot2)
library(purrr)
library(cowplot)

log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file)
sink(log_file, type = "message")
info <- Sys.info();
print(info)
message("making plots")


# TODO: make a better split, because is trying to save in memory too many plots

plot_fun <- purrr::safely(dada2::plotQualityProfile)

ss <- readr::read_tsv("samples2.tsv")

r1_plot <- plot_fun(snakemake@input[1])
r2_plot <- plot_fun(snakemake@input[2])

# r1_plot <- plot_fun(ss$R1[1])
# r2_plot <- plot_fun(ss$R2[1])

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

ggsave(filename = snakemake@output[[1]], final_plot, ggsave, width = 8,
  height = 4, units = "in")

sink(type = "message")
sink()