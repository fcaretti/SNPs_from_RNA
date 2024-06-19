rule annotate_variants:
    input:
        calls="results/calls/calls_gatk.vcf",  # .vcf, .vcf.gz or .bcf
        cache=config['vep']['cache_dir'],  # can be omitted if fasta and gff are specified
        plugins=config['vep']['plugins_dir'],
        # optionally add reference genome fasta
        fasta=reference,
        fai=reference_idx,
        # gff="annotation.gff",
        # csi="annotation.gff.csi", # tabix index
        # add mandatory aux-files required by some plugins if not present in the VEP plugin directory specified above.
        # aux files must be defined as following: "<plugin> = /path/to/file" where plugin must be in lowercase
        # revel = path/to/revel_scores.tsv.gz
    output:
        calls="results/calls/annotated_calls.vcf",  # .vcf, .vcf.gz or .bcf
        stats="results/calls/variants.html",
    params:
        # Pass a list of plugins to use, see https://www.ensembl.org/info/docs/tools/vep/script/vep_plugins.html
        # Plugin args can be added as well, e.g. via an entry "MyPlugin,1,FOO", see docs.
        plugins=["LoFtool"],
        extra="--everything",  # optional: extra arguments
    log:
        "logs/vep/annotate.log",
    threads: 4
    wrapper:
        "v3.12.1/bio/vep/annotate"

rule get_vep_cache:
    output:
        directory(config['vep']['cache_dir']),
    params:
        species=config["vep"]["species"],
        build=config["vep"]["build"],
        release=config["vep"]["release"],
    log:
        "logs/vep/cache.log",
    cache: "omit-software"  # save space and time with between workflow caching (see docs)
    wrapper:
        "v3.12.1/bio/vep/cache"


rule download_vep_plugins:
    output:
        temp(directory(config['vep']['plugins_dir'])),
    params:
        release=config["vep"]["release"],
    wrapper:
        "v3.12.1/bio/vep/plugins"
