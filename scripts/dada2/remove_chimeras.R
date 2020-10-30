## merges different ASV tables, and removes chimeras


sink(snakemake@log[[1]])

info <- Sys.info();
message(stringr::str_c(names(info), " : ", info, "\n"))
print(stringr::str_c(names(info), " : ", info, "\n"))

message("loading package")

library(magrittr)
library(dada2)
library(qs)

seqtab.all <- qs::qread(snakemake@input[["seqtab"]])

# Remove chimeras
message("removing chimeras")
seqtab <- dada2::removeBimeraDenovo(
  seqtab.all,
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

track <- rowSums(seqtab)
names(track) <- row.names(seqtab)

write.table(track, col.names = c("nonchim"),
            snakemake@output[["nreads"]], sep = "\t")
