rule alignment_summary_before_recalibration:
    input:
        ref=reference,
        bam=results_folder + "/split/{sample}.bam",
    output:
        results_folder + "/stats/{sample}_before_recal.summary.txt",
    log:
        "logs/picard/alignment-summary/{sample}.log",
    params:
        extra="--VALIDATION_STRINGENCY LENIENT --METRIC_ACCUMULATION_LEVEL null --METRIC_ACCUMULATION_LEVEL SAMPLE",
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/picard/collectalignmentsummarymetrics"


rule alignment_summary_after_recalibration:
    input:
        ref=reference,
        bam=results_folder + "/recal/{sample}.bam",
    output:
        results_folder + "/stats/{sample}_after_recal.summary.txt",
    log:
        "logs/picard/alignment-summary/{sample}.log",
    params:
        extra="--VALIDATION_STRINGENCY LENIENT --METRIC_ACCUMULATION_LEVEL null --METRIC_ACCUMULATION_LEVEL SAMPLE",
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/picard/collectalignmentsummarymetrics"
