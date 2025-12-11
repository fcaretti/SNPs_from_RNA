rule download_vep_cache:
    output:
        expand(
            "{dir}/{zip_name}",
            dir=config["vep"]["cache_dir"],
            zip_name=config["vep"]["zip_name"],
        ),
    log:
        log_file="logs/vep/download_vep_cache.log",
    params:
        cache_url=lambda wc: config["vep"]["url"],
        directory=config["vep"]["cache_dir"],
    conda:
        "../envs/curl.yml"  # Updated to use a conda environment with curl
    shell:
        """
        mkdir -p {params.directory}
        curl -L -o {output} {params.cache_url} >> {log.log_file} 2>&1
        """


rule unzip_vep_cache:
    input:
        tar_file=expand(
            "{dir}/{zip_name}",
            dir=config["vep"]["cache_dir"],
            zip_name=config["vep"]["zip_name"],
        ),
    output:
        species_dir=directory("{cache_dir}/{species}".format(**config["vep"])),
    log:
        log_file="logs/vep/unzip_vep_cache.log",
    conda:
        "../envs/unzip.yml"
    shell:
        """
        tar -xzvf {input.tar_file} >> {log.log_file} 2>&1
        """


rule vep_annotation:
    input:
        vcf=f"{results_folder}/calls/filtered_calls_gatk.vcf",
        dir="{cache_dir}/{species}".format(**config["vep"]),
    output:
        annotated_vcf=f"{results_folder}/calls/annotated_calls.vcf",
    params:
        cache_dir=lambda wc: config["vep"]["cache_dir"],
        species=lambda wc: config["vep"]["species"],
    container:
        config["vep"]["image"]
    resources:
        cores=4,
    log:
        log_file="logs/vep/vep_annotation.log",
    shell:
        """
        vep --input_file {input.vcf} --output_file {output.annotated_vcf} --offline --vcf --species homo_sapiens \
            --cache --dir_cache {params.cache_dir} --force_overwrite --fork {resources.cores} > {log.log_file} 2>&1
        """
