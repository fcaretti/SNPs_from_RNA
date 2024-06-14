rule splitncigarreads:
    input:
        bam="results/dedup/{sample}.bam",
        ref=reference,
        idx=reference_idx,
        dict=reference_dict,
    output:
        temp("results/split/{sample}.bam"),
    log:
        "logs/splitNCIGARreads/{sample}.log",
    params:
        extra="",  # optional
        java_mem_overhead_mb=512,  # Specify overhead for non-heap memory
    resources:
        mem_mb=4096,  # Total memory available for the rule
    wrapper:
        "v3.12.1/bio/gatk/splitncigarreads"
