rule markduplicates_bam:
    input:
        bams="mapped/{sample}.bam",
    # optional to specify a list of BAMs; this has the same effect
    # of marking duplicates on separate read groups for a sample
    # and then merging
    output:
        bam="dedup_bam/{sample}.bam",
        metrics="dedup_bam/{sample}.metrics.txt",
    log:
        "logs/dedup_bam/{sample}.log",
    params:
        extra="--REMOVE_DUPLICATES true",
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/picard/markduplicates"