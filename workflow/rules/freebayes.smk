# Joint call all BAMs into ONE cohort VCF using the Snakemake freebayes wrapper
rule freebayes:
    input:
        alns=alns,
        ref=reference,
    output:
        vcf=results_folder + "/calls/calls_freebayes.vcf",
    log:
        "logs/freebayes/calls_freebayes.log",
    params:
        extra=(
            f"--min-alternate-fraction {config['variant_calling']['freebayes']['min_alternate_fraction']} "
            f"--min-coverage {config['variant_calling']['freebayes']['min_coverage']} "
            "--pooled-continuous "
            f"--use-best-n-alleles {config['variant_calling']['freebayes']['use_best_n_alleles']} "
            f"--max-complex-gap {config['variant_calling']['freebayes']['max_complex_gap']} "
            "--report-genotype-likelihood-max "
            "--genotype-qualities "
            f"{config['variant_calling']['freebayes']['extra']}"
        ),
        chunksize=config['variant_calling']['freebayes']['chunksize'],
    threads: config['resources']['freebayes']['threads']
    conda:
        "../envs/freebayes-1.3.9.yml"
    resources:
        mem_mb=config['resources']['freebayes']['mem_mb']
    # If you prefer to pin a conda env, keep it here; wrapper will still be used.
    wrapper:
        "v3.12.1/bio/freebayes"
