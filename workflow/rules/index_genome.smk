# Rule to create the FASTA index using samtools
rule samtools_faidx:
    input:
        reference,
    output:
        reference_idx,
    log:
        f"{reference}.log",
    params:
        extra="",
    wrapper:
        "v3.12.1/bio/samtools/faidx"


# Rule to create the sequence dictionary using Picard
rule create_dict:
    input:
        reference,
    output:
        reference_dict,
    log:
        "logs/picard/create_dict.log",
    params:
        extra="",  # Optional: extra arguments for picard.
    resources:
        mem_mb=1024,
    wrapper:
        "v3.12.1/bio/picard/createsequencedictionary"
