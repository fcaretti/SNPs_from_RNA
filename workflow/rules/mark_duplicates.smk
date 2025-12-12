rule markduplicates_bam:
    input:
        bams=results_folder + "/grouped/{sample}.bam",
    output:
        bam=temp(results_folder + "/dedup/{sample}.bam"),
        metrics=results_folder + "/dedup/{sample}.metrics.txt",
    log:
        "logs/dedup_bam/{sample}.log",
    params:
        extra=(
            f"--REMOVE_DUPLICATES {str(config['preprocessing']['mark_duplicates']['remove_duplicates']).lower()} "
            f"{config['preprocessing']['mark_duplicates']['extra']}"
        ),
    threads: config['resources']['mark_duplicates']['threads']
    resources:
        mem_mb=config['resources']['mark_duplicates']['mem_mb'],
    wrapper:
        config['wrappers']['version'] + "/bio/picard/markduplicates"
