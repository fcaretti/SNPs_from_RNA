"""
Per-Caller Variant Filtering

This file implements flexible filtering with the following priority:
1. Caller-specific parameters (e.g., config['filtering']['freebayes']['params'])
2. Default parameters (config['filtering']['default_params'])
3. Percentile-based filtering (if enabled)
4. No filtering (pass-through)

Each variant caller can have its own filtering thresholds optimized for its
characteristics.
"""

# ============================================================================
# Helper Function: Determine Filter Parameters
# ============================================================================
def get_filter_params(caller):
    """
    Get filtering parameters for a specific caller with priority system.

    Priority:
    1. Caller-specific params from config['filtering'][caller]['params']
    2. Default params from config['filtering']['default_params']
    3. Percentile-based filtering (if enabled) - returns "PERCENTILE" marker
    4. Empty string (no filtering)

    Args:
        caller (str): Caller name ('gatk', 'freebayes', or 'deepvariant')

    Returns:
        str: Filter expression or "PERCENTILE" marker or empty string
    """
    # Priority 1: Check for caller-specific params
    caller_params = config.get("filtering", {}).get(caller, {}).get("params", "")
    if caller_params:
        return caller_params

    # Priority 2: Check for default params
    default_params = config.get("filtering", {}).get("default_params", "")
    if default_params:
        return default_params

    # Priority 3: Check if percentile filtering is enabled
    percentile_config = config.get("filtering", {}).get("percentile", {})
    if percentile_config.get("enabled", False):
        return "PERCENTILE"

    # Priority 4: No filtering
    return ""


# ============================================================================
# GATK HaplotypeCaller Filtering
# ============================================================================
rule bcf_filter_gatk:
    input:
        haplo_calls,
    output:
        f"{results_folder}/calls/filtered_calls_gatk.vcf",
    log:
        "logs/filter/filter_gatk.log",
    params:
        filter_expr=get_filter_params("gatk"),
        extra="",
        qual_percentile=config.get('filtering', {}).get('percentile', {}).get('qual_percentile', 10),
        dp_percentile=config.get('filtering', {}).get('percentile', {}).get('dp_percentile', 10),
    threads: config['resources']['bcftools_filter']['threads']
    resources:
        mem_mb=config['resources']['bcftools_filter']['mem_mb']
    conda:
        "../envs/cyvcf2.yml"
    shell:
        """
        if [ "{params.filter_expr}" == "PERCENTILE" ]; then
            echo "WARNING: Using percentile-based filtering (NOT RECOMMENDED for RNA-seq)" > {log}
            python workflow/scripts/percentile_filter.py {input} {output} gatk {params.qual_percentile} {params.dp_percentile} {log}
        elif [ -n "{params.filter_expr}" ]; then
            echo "Applying filter: {params.filter_expr}" > {log}
            bcftools filter {params.filter_expr} {params.extra} -o {output} {input} >> {log} 2>&1
        else
            echo "No filtering parameters specified. Passing through without filtering." > {log}
            cp {input} {output} 2>> {log}
        fi
        """


# ============================================================================
# FreeBayes Filtering
# ============================================================================
rule bcf_filter_freebayes:
    input:
        fb_calls,
    output:
        f"{results_folder}/calls/filtered_calls_freebayes.vcf",
    log:
        "logs/filter/filter_freebayes.log",
    params:
        filter_expr=get_filter_params("freebayes"),
        extra="",
        qual_percentile=config.get('filtering', {}).get('percentile', {}).get('qual_percentile', 10),
        dp_percentile=config.get('filtering', {}).get('percentile', {}).get('dp_percentile', 10),
    threads: config['resources']['bcftools_filter']['threads']
    resources:
        mem_mb=config['resources']['bcftools_filter']['mem_mb']
    conda:
        "../envs/cyvcf2.yml"
    shell:
        """
        if [ "{params.filter_expr}" == "PERCENTILE" ]; then
            echo "WARNING: Using percentile-based filtering (NOT RECOMMENDED for RNA-seq)" > {log}
            python workflow/scripts/percentile_filter.py {input} {output} freebayes {params.qual_percentile} {params.dp_percentile} {log}
        elif [ -n "{params.filter_expr}" ]; then
            echo "Applying filter: {params.filter_expr}" > {log}
            bcftools filter {params.filter_expr} {params.extra} -o {output} {input} >> {log} 2>&1
        else
            echo "No filtering parameters specified. Passing through without filtering." > {log}
            cp {input} {output} 2>> {log}
        fi
        """


# ============================================================================
# DeepVariant Filtering
# ============================================================================
rule bcf_filter_deepvariant:
    input:
        dv_calls,
    output:
        f"{results_folder}/calls/filtered_calls_deepvariant.vcf",
    log:
        "logs/filter/filter_deepvariant.log",
    params:
        filter_expr=get_filter_params("deepvariant"),
        extra="",
        qual_percentile=config.get('filtering', {}).get('percentile', {}).get('qual_percentile', 10),
        dp_percentile=config.get('filtering', {}).get('percentile', {}).get('dp_percentile', 10),
    threads: config['resources']['bcftools_filter']['threads']
    resources:
        mem_mb=config['resources']['bcftools_filter']['mem_mb']
    conda:
        "../envs/cyvcf2.yml"
    shell:
        """
        if [ "{params.filter_expr}" == "PERCENTILE" ]; then
            echo "WARNING: Using percentile-based filtering (NOT RECOMMENDED for RNA-seq)" > {log}
            python workflow/scripts/percentile_filter.py {input} {output} deepvariant {params.qual_percentile} {params.dp_percentile} {log}
        elif [ -n "{params.filter_expr}" ]; then
            echo "Applying filter: {params.filter_expr}" > {log}
            bcftools filter {params.filter_expr} {params.extra} -o {output} {input} >> {log} 2>&1
        else
            echo "No filtering parameters specified. Passing through without filtering." > {log}
            cp {input} {output} 2>> {log}
        fi
        """
