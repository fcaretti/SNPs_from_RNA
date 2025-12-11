rule bcf_filter_o_vcf:
    input:
        haplo_calls,
    output:
        f"{results_folder}/calls/filtered_calls_gatk.vcf",
    log:
        "logs/filter/filter_gatk.vcf.log",
    params:
        filter=config["filtering"]["params"],
        extra="",
    wrapper:
        "v3.12.1/bio/bcftools/filter"

rule bcf_filter_o_vcf_fb:
    input:
        fb_calls,
    output:
        f"{results_folder}/calls/filtered_calls_freebayes.vcf",
    log:
        "logs/filter/filter_fb.vcf.log",
    params:
        filter=config["filtering"]["params"],
        extra="",
    wrapper:
        "v3.12.1/bio/bcftools/filter"

rule bcf_filter_o_vcf_dv:
    input:
        dv_calls,
    output:
        f"{results_folder}/calls/filtered_calls_deepvariant.vcf",
    log:
        "logs/filter/filter_dv.vcf.log",
    params:
        filter=config["filtering"]["params"],
        extra="",
    wrapper:
        "v3.12.1/bio/bcftools/filter"
