# Snakemake workflow: Dada2

[![Snakemake](https://img.shields.io/badge/snakemake-≥5-brightgreen.svg)](https://snakemake.bitbucket.io)
[![dada2](https://img.shields.io/badge/dada2-v1.18-brightgreen.svg)](https://benjjneb.github.io/dada2/index.html)
<!-- [![Build Status](https://travis-ci.org/snakemake-workflows/amplicon-seq-dada2.svg?branch=master)](https://travis-ci.org/snakemake-workflows/amplicon-seq-dada2) -->


This workflow is an implementation of the popular DADA2 tool. I followed the steps in the [Tutorial](https://benjjneb.github.io/dada2/tutorial.html). I use IDtaxa for taxonomic annotation.

![dada2](https://benjjneb.github.io/dada2/images/DADA2_Logo_Text_1_14_640px.png)

The pipeline was inspired by the [dada2 snakemake pipeline by Silas Kieser (@silask)](https://github.com/SilasK/16S-dada2).

## Authors

*  Rene Welch (@ReneWelch)

## Usage

### Install workflow


#### Install snakemake pipeline

Assuming [conda](https://docs.conda.io/en/latest/) is already installed, and a copy of this repository has been downloaded. Then, the pipeline can be installed by:

```sh
conda env create -n {env_name} --file dependencies.yml
```

#### Install R packages

This pipeline strongly depends on R package, therefore we utilized [renv](https://rstudio.github.io/renv/index.html) to set the right R package versions.

After `renv` is installed, utilize:

```R
renv::restore()
```

to install all the R libraries used in the pipeline

### Run workflow

* `snakemake -j{cores} all_profile` to plot the quality profiles
* `snakemake -j{cores}` to run the dada2 pipeline
* `snakemake -j{cores} all_taxonomy_kraken` to labels the ASV sequences with [kraken2](https://ccb.jhu.edu/software/kraken2/). Databases need to be downloaded from https://benlangmead.github.io/aws-indexes/k2
* `snakemake -j{cores} all_phyloseq` to perform the generate a `phyloseq` object, align sequences and compute the alpha / beta diversities


<!-- ## Usage

### Step 1: Install workflow

If you simply want to use this workflow, download and extract the [latest release](https://github.com/snakemake-workflows/amplicon-seq-dada2/releases).
If you intend to modify and further develop this workflow, fork this repository. Please consider providing any generally applicable modifications via a pull request.

In any case, if you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repository and, if available, its DOI (see above).

#### Requirements:

The pipeline has some dependencies which an be installed with conda:

```
conda env create -n dada2_env --file dependencies.yml

```

#### Databases:

For taxonomic annotation I use IDtaxa. A database e.g. the one from GTDB should be downloaded from [here](http://www2.decipher.codes/Downloads.html) and the path added to the config file.

### Step 2: Configure workflow

Configure the workflow according to your needs via editing the file `config.yaml`.

Create a sample table like [this one](.test/samples.tsv). You can use the script `prepare_sample_table.py` for it. The scripts searches for fastq(.gz) files inside a folder (structure). If you have paired end files they should have R1/R2 somewhere in the filename. If might be a good idea to simplify sample names.

```
prepare_sample_table.py path/to/fasqfiles
```


### Step 3: Execute workflow

Test your configuration by performing a dry-run via

    snakemake -n

Execute the workflow locally via

    snakemake --cores $N

using `$N` cores or run it in a cluster environment via

    snakemake --cluster qsub --jobs 100

or

    snakemake --drmaa --jobs 100

See the [Snakemake documentation](https://snakemake.readthedocs.io) for further details.

## Testing

You can test the pipeline with the script `test.py`. -->


## Cite

#### dada2

Callahan, B., McMurdie, P., Rosen, M. et al. DADA2: High-resolution sample inference from Illumina amplicon data. Nat Methods 13, 581–583 (2016). https://doi.org/10.1038/nmeth.3869

#### Kraken2:

Wood, D., Lu, J., Langmead, B. Improved metagenomic analysis with Kraken 2. Genome Biology 20, 257 (2019). https://doi.org/10.1186/s13059-019-1891-0

#### phyloseq

McMurdie, P., Holmes, S. phyloseq: An R Package for Reproducible Interactive Analysis and Graphics of Microbiome Census Data. PLOS One 8, 4 (2013). https://doi.org/10.1371/journal.pone.0061217

<!-- #### IDtaxa:

Murali, A., Bhargava, A. & Wright, E.S. IDTAXA: a novel approach for accurate taxonomic classification of microbiome sequences. Microbiome 6, 140 (2018). https://doi.org/10.1186/s40168-018-0521-5 -->
