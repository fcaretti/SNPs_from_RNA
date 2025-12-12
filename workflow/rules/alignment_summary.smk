rule alignment_summary_before_recalibration:
    input:
        ref=reference,
        bam=results_folder + "/split/{sample}.bam",
    output:
        results_folder + "/stats/{sample}_before_recal.summary.txt",
    log:
        "logs/picard/alignment-summary/{sample}.log",
    params:
        extra=(
            f"--VALIDATION_STRINGENCY {config['preprocessing']['alignment_summary']['validation_stringency']} "
            f"--METRIC_ACCUMULATION_LEVEL null "
            f"--METRIC_ACCUMULATION_LEVEL {config['preprocessing']['alignment_summary']['metric_accumulation_level']} "
            f"{config['preprocessing']['alignment_summary']['extra']}"
        ),
    threads: config["resources"]["alignment_summary"]["threads"]
    resources:
        mem_mb=config["resources"]["alignment_summary"]["mem_mb"],
    wrapper:
        config["wrappers"]["version"] + "/bio/picard/collectalignmentsummarymetrics"


rule alignment_summary_after_recalibration:
    input:
        ref=reference,
        bam=results_folder + "/recal/{sample}.bam",
    output:
        results_folder + "/stats/{sample}_after_recal.summary.txt",
    log:
        "logs/picard/alignment-summary/{sample}.log",
    params:
        extra=(
            f"--VALIDATION_STRINGENCY {config['preprocessing']['alignment_summary']['validation_stringency']} "
            f"--METRIC_ACCUMULATION_LEVEL null "
            f"--METRIC_ACCUMULATION_LEVEL {config['preprocessing']['alignment_summary']['metric_accumulation_level']} "
            f"{config['preprocessing']['alignment_summary']['extra']}"
        ),
    threads: config["resources"]["alignment_summary"]["threads"]
    resources:
        mem_mb=config["resources"]["alignment_summary"]["mem_mb"],
    wrapper:
        config["wrappers"]["version"] + "/bio/picard/collectalignmentsummarymetrics"
