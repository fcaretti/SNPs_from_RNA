rule haplotype_caller:
    input:
        # single or list of bam files
        bam="results/recal/{sample}.bam",
        ref=reference,
    output:
        vcf="results/calls_gatk/{sample}.vcf",
    log:
        "logs/gatk/haplotypecaller/{sample}.log",
    params:
        extra="",  # optional
        java_opts="",  # optional
    threads: 4
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/gatk/haplotypecaller"


rule merge_vcfs:
    input:
        vcfs=vcfs,
    output:
        "results/calls/calls_gatk.vcf",
    log:
        "logs/picard/mergevcfs.log",
    params:
        extra="",
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/picard/mergevcfs"