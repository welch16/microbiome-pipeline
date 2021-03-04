import os
import pandas as pd

configfile: "config.yaml"

# SampleTable = pd.read_table("samples2.tsv", index_col = 0)
SampleTable = pd.read_table(config['sampletable'], index_col=0)
sample_dict = SampleTable.to_dict('index')
SAMPLES = list(SampleTable.index)

JAVA_MEM_FRACTION=0.85
CONDAENV ='envs'
PAIRED_END= ('R2' in SampleTable.columns)
FRACTIONS= ['R1']
if PAIRED_END: FRACTIONS+= ['R2']

# def get_taxonomy_names():

#     if 'idtaxa_dbs' in config and config['idtaxa_dbs'] is not None:
#         return config['idtaxa_dbs'].keys()
#     else:
#         return []

rule all:
  input:
    "data/model/error_rates_R1.qs",
    "data/model/error_rates_R2.qs",
    "data/stats/Nreads_dada2.txt",
    "data/asv/seqtab_nochimeras_qc.qs"

rule all_profile:
    input: expand("figures/quality_profiles/{sample}.png", sample = SAMPLES)

rule all_taxonomy_kraken:
  input:
    "data/fasta/asv_sequences.fa",
    "data/taxonomy/kraken_minikraken2_labels.qs"
    
rule all_phyloseq:
  input:
    "data/phyloseq/asv_phyloseq.qs",
    "data/phyloseq/asv_phyloseq_norm.qs",
    "data/phyloseq/div/alphadiv.qs"
    # "data/phyloseq/div/betadiv.qs"
    # "data/phyloseq/div/unifrac_dist.qs"

rule clean:
  shell:
    """rm -r data/asv data/filtered data/stats data/model \
        data/fasta data/taxonomy data/phyloseq logs"""

rule clean_phyloseq:
  shell:
    """rm -r data/phyloseq"""

include: "rules/quality_control.smk"
include: "rules/dada2.smk"
include: "rules/taxonomy.smk"
include: "rules/phyloseq.smk"
