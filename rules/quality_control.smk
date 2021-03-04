
rule plot_quality_profiles:
  input:
    lambda wc: [sample_dict[wc.sample]["R1"], sample_dict[wc.sample]["R2"]]
  log:
    "logs/qc/plot_qc_profiles_{sample}.logs"
  output:
    "figures/quality_profiles/{sample}.png"
  script:
    "../scripts/dada2/plot_quality_profiles.R"

rule fastqc:
  input:
    R1 = SampleTable.R1.values,
    R2 = SampleTable.R2.values
  params:
    threads = config["threads"]
  output:
    html=expand("data/quality_control/fastqc/{sample}_fastqc.html", sample = allvalues),
    zip=expand("data/quality_control/fastqc/{sample}_fastqc.zip", sample = allvalues)
  log:
    "logs/qc/fastqc.txt"
  shell:
    """fastqc -o data/quality_control/fastqc -t {params.threads} {input.R1} {input.R2}"""
    
rule multiqc:
  input:
    expand("data/quality_control/fastqc/{sample}_fastqc.html", sample = allvalues)
  output:
    "data/quality_control/multiqc/multiqc_report.html"
  shell:
    """multiqc data/quality_control -o data/quality_control/multiqc"""