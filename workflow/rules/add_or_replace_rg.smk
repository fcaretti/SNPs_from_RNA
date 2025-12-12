# Note: input_bam_folder is defined in Snakefile (either data_folder or filtered_bams folder)


rule replace_rg:
    input:
        os.path.join(input_bam_folder, "{sample}.bam"),
    output:
        temp(results_folder + "/grouped/{sample}.bam"),
    log:
        "logs/replace_rg/{sample}.log",
    params:
        extra=(
            f"--RGID {{sample}} "
            f"--RGLB {config['preprocessing']['read_groups']['library']} "
            f"--RGPL {config['preprocessing']['read_groups']['platform']} "
            f"--RGPU {{sample}} "
            f"--RGSM {{sample}} "
            f"{config['preprocessing']['read_groups']['extra']}"
        ),
    threads: config['resources']['add_replace_rg']['threads']
    resources:
        mem_mb=config['resources']['add_replace_rg']['mem_mb'],
    wrapper:
        config['wrappers']['version'] + "/bio/picard/addorreplacereadgroups"
