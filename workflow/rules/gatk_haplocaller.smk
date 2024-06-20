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


rule bgzip:
    input:
        "results/calls_gatk/{sample}.vcf",
    output:
        temp("results/calls_gatk/{sample}.vcf.gz"),
    params:
        extra="",  # optional
    threads: 1
    log:
        "logs/bgzip/{sample}.log",
    wrapper:
        "v3.12.1-7-ge5bfa94/bio/bgzip"


rule bcftools_index:
    input:
        "results/calls_gatk/{sample}.vcf.gz",
    output:
        temp("results/calls_gatk/{sample}.vcf.csi"),
    log:
        "logs/index/{sample}.log",
    params:
        extra="-c",  # optional parameters for bcftools index
    wrapper:
        "v3.12.1/bio/bcftools/index"


rule bcftools_merge:
    input:
        calls=vcf_zips,
        idx=vcf_idxs,
    output:
        "results/calls/calls_gatk.vcf",
    log:
        "logs/merge/merge_vcf.log",
    params:
        uncompressed_bcf=True,
        extra="",  # optional parameters for bcftools concat (except -o)
    wrapper:
        "v3.12.1/bio/bcftools/merge"
