The starting point of the pipeline are .bam files from one or more RNA samples. They are assumed to have been already sequenced.
Edit the config/config.yml file as follows:
* data:
    1) ["folder"]: path to the folder containing the .bam files
* reference:
    1) ["folder"]: the folder containing the .fa file
    2) ["genome"]: the genome file
* known_sites: used only in FreeBayes, and not GATK's HaplotypeCaller. Currently not used
* filtering:
    1) ["params"]: the parameters for bcftools filter. An example is provided
* vep:
    1) cache_dir: directory in which the VEP cache should be downloaded
    2) zip_name: name of the zip file to download
    3) url: complete URL of the file to download
    4) image: docker image on which to create a container with Docker or Singularity
    5) filters: "--filter "
    6) impact_levels: select the impact level, as a list of strings (ex. ["MODERATE", "HIGH"]
    7) species: currently only needed to give a directory name
