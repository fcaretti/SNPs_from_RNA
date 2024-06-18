rule markduplicates_bam:
    input:
        bams="results/grouped/{sample}.bam",
    output:
        bam=temp("results/dedup/{sample}.bam"),
        metrics="results/dedup/{sample}.metrics.txt",
    log:
        "logs/dedup_bam/{sample}.log",
    params:
        extra="--REMOVE_DUPLICATES true",
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/picard/markduplicates"
