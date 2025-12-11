import os, glob

# Discover samples
SAMPLES = [os.path.basename(p).replace(".bam","")
           for p in glob.glob(results_folder + "/dedup/*.bam")]

rule sanitize_bam_for_splitncigar:
    input:
        bam = results_folder + "/dedup/{sample}.bam",
        dict = reference_dict
    output:
        bam = results_folder + "/sanitized/{sample}.bam",
        bai = results_folder + "/sanitized/{sample}.bam.bai"
    threads: 4
    log: results_folder + "/logs/sanitize/{sample}.log"
    shell:
        """
        # Create directories first
        mkdir -p {results_folder}/sanitized
        mkdir -p {results_folder}/logs/sanitize
        
        # Redirect all output to log
        exec >> {log} 2>&1
        set -x
        
        echo "Starting sanitization for {wildcards.sample}"
        
        # Get valid contigs
        grep "^@SQ" {input.dict} | cut -f2 | sed 's/SN://' > {output.bam}.contigs.txt
        
        echo "Valid contigs extracted"
        
        # Create new header
        samtools view -H {input.bam} | grep "^@HD" > {output.bam}.header.sam || printf "@HD\\tVN:1.6\\tSO:coordinate\\n" > {output.bam}.header.sam
        grep "^@SQ" {input.dict} >> {output.bam}.header.sam
        samtools view -H {input.bam} | grep -E "^@RG|^@PG|^@CO" >> {output.bam}.header.sam || true
        
        echo "Header created"
        
        # Filter reads by valid contigs using awk
        {{
            cat {output.bam}.header.sam
            samtools view {input.bam} | awk 'NR==FNR{{ok[$1]=1;next}} ($3=="*" || ok[$3])' {output.bam}.contigs.txt -
        }} | samtools view -b - | samtools sort -@ {threads} -o {output.bam} -
        
        echo "BAM filtered and sorted"
        
        # Index
        samtools index -@ {threads} {output.bam}
        
        echo "BAM indexed"
        
        # Cleanup
        rm -f {output.bam}.contigs.txt {output.bam}.header.sam
        
        echo "Sanitization complete for {wildcards.sample}"
        """