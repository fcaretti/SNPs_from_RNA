# Access the data folder from the config
data_folder = config["data"]["folder"]


rule replace_rg:
    input:
        lambda wildcards: os.path.join(data_folder, f"{wildcards.sample}.bam"),
    output:
        temp("results/grouped/{sample}.bam"),
    log:
        "logs/replace_rg/{sample}.log",
    params:
        extra="--RGID {sample} --RGLB lib1 --RGPL illumina --RGPU {sample} --RGSM {sample}",
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/picard/addorreplacereadgroups"
