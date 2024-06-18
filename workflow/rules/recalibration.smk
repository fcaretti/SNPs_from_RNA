rule gatk_baserecalibrator:
    input:
        bam="results/split/{sample}.bam",
        ref=reference,
        dict=reference_dict,
        known=known_sites,
    output:
        recal_table="results/recal_tables/{sample}.grp",
    log:
        "logs/baserecalibrator/{sample}.log",
    params:
        extra="",  # optional
        java_opts="",  # optional
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/gatk/baserecalibrator"


rule gatk_applybqsr:
    input:
        bam="results/split/{sample}.bam",
        ref=reference,
        dict=reference_dict,
        recal_table="results/recal_tables/{sample}.grp",
    output:
        bam="results/recal/{sample}.bam",
        bai="results/recal/{sample}.bai",
    log:
        "logs/gatk_applybqsr/{sample}.log",
    params:
        extra="",  # optional
        java_opts="",  # optional
        embed_ref=True,  # embed the reference in cram output
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/gatk/applybqsr"
