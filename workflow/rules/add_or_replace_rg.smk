# Access the data folder from the config
data_folder = config["data"]["folder"]
SAMPLES = glob_wildcards(os.path.join(data_folder, "{sample}.bam")).sample


rule replace_rg:
    input:
        os.path.join(data_folder, "{sample}.bam"),
    output:
        temp(results_folder + "/grouped/{sample}.bam"),
    log:
        "logs/replace_rg/{sample}.log",
    params:
        extra="--RGID {sample} --RGLB lib1 --RGPL illumina --RGPU {sample} --RGSM {sample}",
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/picard/addorreplacereadgroups"
