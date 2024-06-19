rule bcf_filter_o_vcf:
    input:
        haplo_calls,
    output:
        "results/calls/filtered_calls.vcf",
    log:
        "logs/filter/filter.vcf.log",
    params:
        filter=config["filtering"]["params"],
        extra="",
    wrapper:
        "v3.12.1/bio/bcftools/filter"
