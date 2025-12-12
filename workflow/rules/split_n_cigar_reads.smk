rule splitncigarreads:
    input:
        bam=results_folder + "/sanitized/{sample}.bam",
        ref=reference,
        idx=reference_idx,
        dict=reference_dict,
    output:
        temp(results_folder + "/split/{sample}.bam"),
    log:
        "logs/splitNCIGARreads/{sample}.log",
    params:
        extra=config["preprocessing"]["split_n_cigar"]["extra"],
        java_mem_overhead_mb=config["preprocessing"]["split_n_cigar"][
            "java_mem_overhead_mb"
        ],
    threads: config["resources"]["split_n_cigar"]["threads"]
    resources:
        mem_mb=config["resources"]["split_n_cigar"]["mem_mb"],
    wrapper:
        config["wrappers"]["version"] + "/bio/gatk/splitncigarreads"
