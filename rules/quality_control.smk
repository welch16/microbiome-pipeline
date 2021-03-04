
rule plot_quality_profiles:
  input:
    lambda wc: [sample_dict[wc.sample]["R1"], sample_dict[wc.sample]["R2"]]
  log:
    "logs/dada2/plot_qc_profiles_{sample}.logs"
  output:
    "figures/quality_profiles/{sample}.png"
  script:
    "../scripts/dada2/plot_quality_profiles.R"
