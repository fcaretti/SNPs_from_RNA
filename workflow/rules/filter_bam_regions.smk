"""
BAM Filtering by Chromosomes/Regions

This rule filters input BAM files to retain only specified chromosomes or genomic regions.
This is optional and controlled by config['bam_filtering']['enabled'].

Use cases:
- Analyze only autosomes (exclude X, Y, MT)
- Focus on specific chromosomes (e.g., chr1-chr22)
- Exclude decoy sequences and unplaced contigs
- Speed up analysis by reducing data size
"""

rule filter_bam_regions:
    input:
        bam=data_folder + "/{sample}.bam",
        bai=data_folder + "/{sample}.bam.bai",
    output:
        bam=results_folder + "/filtered_bams/{sample}.bam",
        bai=results_folder + "/filtered_bams/{sample}.bam.bai",
    params:
        regions=lambda wildcards: " ".join(config.get('bam_filtering', {}).get('regions', [])),
        bed_file=lambda wildcards: config.get('bam_filtering', {}).get('bed_file', ''),
    log:
        "logs/filter_bam/{sample}.log"
    threads:
        config.get('resources', {}).get('filter_bam', {}).get('threads', 4)
    conda:
        "../envs/samtools.yml"
    shell:
        """
        # Filter BAM file by regions or BED file
        if [ -n "{params.bed_file}" ] && [ -f "{params.bed_file}" ]; then
            echo "Filtering BAM using BED file: {params.bed_file}" > {log}
            samtools view -b -L {params.bed_file} -@ {threads} {input.bam} > {output.bam} 2>> {log}
        elif [ -n "{params.regions}" ]; then
            echo "Filtering BAM for regions: {params.regions}" > {log}
            samtools view -b -@ {threads} {input.bam} {params.regions} > {output.bam} 2>> {log}
        else
            echo "No filtering specified, copying BAM file" > {log}
            cp {input.bam} {output.bam} 2>> {log}
        fi

        # Index the output BAM
        echo "Indexing filtered BAM" >> {log}
        samtools index -@ {threads} {output.bam} 2>> {log}
        """
