rule gatk_baserecalibrator:
    input:
        bam=results_folder + "/split/{sample}.bam",
        ref=reference,
        dict=reference_dict,
        known=known_sites,
    output:
        recal_table=results_folder + "/recal_tables/{sample}.grp",
    log:
        "logs/baserecalibrator/{sample}.log",
    params:
        extra=config["preprocessing"]["base_recalibration"]["extra"],
        java_opts=config["preprocessing"]["base_recalibration"]["java_opts"],
    threads: config["resources"]["base_recalibrator"]["threads"]
    resources:
        mem_mb=config["resources"]["base_recalibrator"]["mem_mb"],
    wrapper:
        config["wrappers"]["version"] + "/bio/gatk/baserecalibrator"


rule gatk_applybqsr:
    input:
        bam=results_folder + "/split/{sample}.bam",
        ref=reference,
        dict=reference_dict,
        recal_table=results_folder + "/recal_tables/{sample}.grp",
    output:
        bam=results_folder + "/recal/{sample}.bam",
        bai=results_folder + "/recal/{sample}.bai",
    log:
        "logs/gatk_applybqsr/{sample}.log",
    params:
        extra=config["preprocessing"]["apply_bqsr"]["extra"],
        java_opts=config["preprocessing"]["apply_bqsr"]["java_opts"],
        embed_ref=config["preprocessing"]["apply_bqsr"]["embed_ref"],
    threads: config["resources"]["apply_bqsr"]["threads"]
    resources:
        mem_mb=config["resources"]["apply_bqsr"]["mem_mb"],
    wrapper:
        config["wrappers"]["version"] + "/bio/gatk/applybqsr"
