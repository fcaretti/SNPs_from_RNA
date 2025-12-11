# DeepVariant variant calling (using Singularity)
rule deepvariant:
    input:
        bam=results_folder + "/recal/{sample}.bam",
        bai=results_folder + "/recal/{sample}.bai",
        ref=reference,
        fai=reference_idx,
    output:
        vcf=results_folder + "/calls_deepvariant/{sample}.vcf.gz",
        gvcf=results_folder + "/calls_deepvariant/{sample}.g.vcf.gz",
    log:
        "logs/deepvariant/{sample}.log",
    params:
        model_type="WGS",
        extra="",
    threads: 8
    resources:
        mem_mb=16384,
    container:
        "docker://google/deepvariant:1.6.1"
    shell:
        """
        export TMPDIR=/tmp  # Use container's /tmp instead
        /opt/deepvariant/bin/run_deepvariant \
            --model_type={params.model_type} \
            --ref={input.ref} \
            --reads={input.bam} \
            --output_vcf={output.vcf} \
            --output_gvcf={output.gvcf} \
            --num_shards={threads} \
            {params.extra} \
            2> {log}"""

            
# Index DeepVariant VCFs (same as GATK)
rule deepvariant_bcftools_index:
    input:
        results_folder + "/calls_deepvariant/{sample}.vcf.gz",
    output:
        temp(results_folder + "/calls_deepvariant/{sample}.vcf.csi"),
    log:
        "logs/deepvariant_index/{sample}.log",
    params:
        extra="-c",
    wrapper:
        "v3.12.1/bio/bcftools/index"

# Merge DeepVariant calls (same as GATK)
rule merge_deepvariant:
    input:
        calls=expand(results_folder + "/calls_deepvariant/{sample}.vcf.gz", sample=samples),
        idx=expand(results_folder + "/calls_deepvariant/{sample}.vcf.csi", sample=samples),
    output:
        results_folder + "/calls/calls_deepvariant.vcf",
    log:
        "logs/merge/merge_deepvariant.log",
    params:
        uncompressed_bcf=False,
        extra="",
    wrapper:
        "v3.12.1/bio/bcftools/merge"