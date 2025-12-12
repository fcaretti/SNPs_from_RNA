rule haplotype_caller:
    input:
        # single or list of bam files
        bam=results_folder + "/recal/{sample}.bam",
        ref=reference,
    output:
        vcf=results_folder + "/calls_gatk/{sample}.vcf",
    log:
        "logs/gatk/haplotypecaller/{sample}.log",
    params:
        extra=config['variant_calling']['gatk']['extra'],
        java_opts=config['variant_calling']['gatk']['java_opts'],
    threads: config['resources']['gatk_haplotypecaller']['threads']
    resources:
        mem_mb=config['resources']['gatk_haplotypecaller']['mem_mb'],
    wrapper:
        config['wrappers']['version'] + "/bio/gatk/haplotypecaller"


rule bgzip:
    input:
        results_folder + "/calls_gatk/{sample}.vcf",
    output:
        temp(results_folder + "/calls_gatk/{sample}.vcf.gz"),
    params:
        extra="",  # optional
    threads: config['resources']['bgzip']['threads']
    resources:
        mem_mb=config['resources']['bgzip']['mem_mb']
    log:
        "logs/bgzip/{sample}.log",
    wrapper:
        config['wrappers']['version'] + "/bio/bgzip"


rule bcftools_index:
    input:
        results_folder + "/calls_gatk/{sample}.vcf.gz",
    output:
        temp(results_folder + "/calls_gatk/{sample}.vcf.csi"),
    log:
        "logs/index/{sample}.log",
    params:
        extra=config['variant_calling']['gatk']['index_extra'],
    threads: config['resources']['bcftools_index']['threads']
    resources:
        mem_mb=config['resources']['bcftools_index']['mem_mb']
    wrapper:
        config['wrappers']['version'] + "/bio/bcftools/index"


rule bcftools_merge:
    input:
        calls=vcf_zips,
        idx=vcf_idxs,
    output:
        results_folder + "/calls/calls_gatk.vcf",
    log:
        "logs/merge/merge_vcf.log",
    params:
        uncompressed_bcf=False,
        extra=config['variant_calling']['gatk']['merge_extra'],
    threads: config['resources']['bcftools_merge']['threads']
    resources:
        mem_mb=config['resources']['bcftools_merge']['mem_mb']
    wrapper:
        config['wrappers']['version'] + "/bio/bcftools/merge"
