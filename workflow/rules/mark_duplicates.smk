rule markduplicates_bam:
    input:
        bams=results_folder + "/grouped/{sample}.bam",
    output:
        bam=temp(results_folder + "/dedup/{sample}.bam"),
        metrics=results_folder + "/dedup/{sample}.metrics.txt",
    log:
        "logs/dedup_bam/{sample}.log",
    params:
        extra="--REMOVE_DUPLICATES true",
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/picard/markduplicates"
