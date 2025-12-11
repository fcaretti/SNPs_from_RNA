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
            f"--min-alternate-fraction {config['freebayes']['min_alternate_fraction']} "
            f"--min-coverage {config['freebayes']['min_coverage']} "
            "--pooled-continuous "
            f"--use-best-n-alleles {config['freebayes']['use_best_n_alleles']} "
            f"--max-complex-gap {config['freebayes']['max_complex_gap']} "
            "--report-genotype-likelihood-max "
            "--genotype-qualities"
        ),
        chunksize=config['freebayes']['chunksize'],
    threads: 32         
    conda:
        "../envs/freebayes-1.3.9.yaml"
    resources:
        mem_mb=4096
    # If you prefer to pin a conda env, keep it here; wrapper will still be used.
    wrapper:
        "v3.12.1/bio/freebayes"
