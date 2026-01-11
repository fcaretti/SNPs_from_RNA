rule splitncigarreads:
    input:
        bam=results_folder + "/sanitized/{sample}.bam",
        ref=reference,
        idx=reference_idx,
        dict=reference_dict,
    output:
        # Not marked as temp() because if BQSR is disabled, these are the final BAMs
        # If BQSR is enabled, Snakemake will still clean them up as intermediates
        results_folder + "/split/{sample}.bam",
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


# Index split BAMs (needed when BQSR is disabled)
rule index_split_bams:
    input:
        results_folder + "/split/{sample}.bam",
    output:
        results_folder + "/split/{sample}.bai",
    log:
        "logs/index_split/{sample}.log",
    threads: 1
    resources:
        mem_mb=1024,
    conda:
        "../envs/samtools.yml"
    shell:
        "samtools index -@ {threads} {input} {output} 2> {log}"
