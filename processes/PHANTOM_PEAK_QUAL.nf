process PHANTOM_PEAK_QUAL {
    label 'process_medium'

    debug false

    input:
    tuple val(meta), val(bam)
    output:
    tuple val(meta), val("${params.publish_dir}/01qc/phantompeakqual/${meta.sample}.spp.out")

    script:
    """
    mkdir -p ${params.publish_dir}/01qc/phantompeakqual
    mkdir -p ${params.publish_dir}/00log/phantompeakqual
    echo "Phantoming ${bam}" 
    Rscript --vanilla ${params.ext_scripts}/run_spp_nodups.R \
    -c=${bam} -savp -rf -p=6 -odir=${params.publish_dir}/01qc/phantompeakqual  -out=${params.publish_dir}/01qc/phantompeakqual/${meta.sample}.spp.out -tmpdir=${params.publish_dir}/01qc/phantompeakqual  2> ${params.publish_dir}/00log/phantompeakqual/${meta.sample}_phantompeakqual.log
    """

}