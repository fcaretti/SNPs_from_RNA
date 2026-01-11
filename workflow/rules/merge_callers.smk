"""
Multi-Caller Merge Strategies

This file contains rules for merging VCF files from multiple variant callers.
Two strategies are supported:

1. OR (Union): Combine all variants from all callers (maximum sensitivity)
   - A variant is reported if ANY caller detects it
   - Uses bcftools merge

2. AND (Intersection): Keep only variants called by ALL callers (maximum specificity)
   - A variant is reported ONLY if ALL callers detect it
   - Uses bcftools isec (intersection)

The strategy is controlled by config['variant_calling']['merge_strategy']
"""


# ============================================================================
# Helper Rules: Compress and Index Filtered VCFs for Merging
# ============================================================================
# bcftools merge requires bgzipped and indexed VCF files
# These rules compress the plain text filtered VCFs and create tabix indices

rule bgzip_filtered_freebayes:
    input:
        f"{results_folder}/calls/filtered_calls_freebayes.vcf",
    output:
        temp(f"{results_folder}/calls/filtered_calls_freebayes.vcf.gz"),
    threads: config["resources"]["bgzip"]["threads"]
    resources:
        mem_mb=config["resources"]["bgzip"]["mem_mb"],
    conda:
        "../envs/bcftools.yml"
    shell:
        "bgzip -c {input} > {output}"


rule bgzip_filtered_gatk:
    input:
        f"{results_folder}/calls/filtered_calls_gatk.vcf",
    output:
        temp(f"{results_folder}/calls/filtered_calls_gatk.vcf.gz"),
    threads: config["resources"]["bgzip"]["threads"]
    resources:
        mem_mb=config["resources"]["bgzip"]["mem_mb"],
    conda:
        "../envs/bcftools.yml"
    shell:
        "bgzip -c {input} > {output}"


rule bgzip_filtered_deepvariant:
    input:
        f"{results_folder}/calls/filtered_calls_deepvariant.vcf",
    output:
        temp(f"{results_folder}/calls/filtered_calls_deepvariant.vcf.gz"),
    threads: config["resources"]["bgzip"]["threads"]
    resources:
        mem_mb=config["resources"]["bgzip"]["mem_mb"],
    conda:
        "../envs/bcftools.yml"
    shell:
        "bgzip -c {input} > {output}"


rule tabix_filtered_freebayes:
    input:
        f"{results_folder}/calls/filtered_calls_freebayes.vcf.gz",
    output:
        temp(f"{results_folder}/calls/filtered_calls_freebayes.vcf.gz.tbi"),
    conda:
        "../envs/bcftools.yml"
    shell:
        "tabix -p vcf {input}"


rule tabix_filtered_gatk:
    input:
        f"{results_folder}/calls/filtered_calls_gatk.vcf.gz",
    output:
        temp(f"{results_folder}/calls/filtered_calls_gatk.vcf.gz.tbi"),
    conda:
        "../envs/bcftools.yml"
    shell:
        "tabix -p vcf {input}"


rule tabix_filtered_deepvariant:
    input:
        f"{results_folder}/calls/filtered_calls_deepvariant.vcf.gz",
    output:
        temp(f"{results_folder}/calls/filtered_calls_deepvariant.vcf.gz.tbi"),
    conda:
        "../envs/bcftools.yml"
    shell:
        "tabix -p vcf {input}"


# ============================================================================
# OR Strategy (Union): Merge all variants from all callers
# ============================================================================
rule merge_callers_union:
    input:
        vcfs=[f"{results_folder}/calls/filtered_calls_{caller}.vcf.gz" for caller in enabled_callers],
        indices=[f"{results_folder}/calls/filtered_calls_{caller}.vcf.gz.tbi" for caller in enabled_callers],
    output:
        vcf=results_folder + "/calls/merged_union.vcf",
    log:
        "logs/merge/merge_union.log",
    params:
        # --force-samples: Allow sample name mismatches
        # -m none: Do not merge into a single record (keep all INFO from all callers)
        extra="--force-samples -m none",
    threads: config["resources"]["bcftools_merge"]["threads"]
    resources:
        mem_mb=config["resources"]["bcftools_merge"]["mem_mb"],
    conda:
        "../envs/bcftools.yml"
    shell:
        """
        echo "Merging VCF files using OR (union) strategy" > {log}
        echo "Input VCFs: {input.vcfs}" >> {log}

        bcftools merge {params.extra} -o {output.vcf} {input.vcfs} >> {log} 2>&1

        echo "Merge complete. Output: {output.vcf}" >> {log}
        """


# ============================================================================
# AND Strategy (Intersection): Keep only variants called by ALL callers
# ============================================================================
rule merge_callers_intersection:
    input:
        vcfs=[f"{results_folder}/calls/filtered_calls_{caller}.vcf.gz" for caller in enabled_callers],
        indices=[f"{results_folder}/calls/filtered_calls_{caller}.vcf.gz.tbi" for caller in enabled_callers],
    output:
        vcf=results_folder + "/calls/merged_intersection.vcf",
        temp_dir=temp(directory(results_folder + "/calls/isec_tmp")),
    log:
        "logs/merge/merge_intersection.log",
    params:
        n_callers=len(enabled_callers),
    threads: config["resources"]["bcftools_merge"]["threads"]
    resources:
        mem_mb=config["resources"]["bcftools_merge"]["mem_mb"],
    conda:
        "../envs/bcftools.yml"
    shell:
        """
        echo "Merging VCF files using AND (intersection) strategy" > {log}
        echo "Input VCFs: {input.vcfs}" >> {log}
        echo "Number of callers: {params.n_callers}" >> {log}

        # Create temporary directory for bcftools isec output
        mkdir -p {output.temp_dir}

        # Use bcftools isec to find intersection
        # -n ={params.n_callers}: Output sites present in all N files
        # -p: Output directory prefix
        # -w1: Write output using first file's format
        echo "Running bcftools isec to find variants in all {params.n_callers} callers..." >> {log}
        bcftools isec -n ={params.n_callers} -w1 -p {output.temp_dir} {input.vcfs} >> {log} 2>&1

        # The intersection is in 0000.vcf (or similar numbered files)
        # Move the intersection output to final location
        if [ -f {output.temp_dir}/0000.vcf ]; then
            mv {output.temp_dir}/0000.vcf {output.vcf}
            echo "Intersection complete. Output: {output.vcf}" >> {log}
        else
            echo "ERROR: No intersection found. Check if input VCFs have compatible formats." >> {log}
            exit 1
        fi
        """
