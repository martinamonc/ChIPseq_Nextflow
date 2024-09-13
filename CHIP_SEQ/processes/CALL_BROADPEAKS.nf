process CALL_BROADPEAKS {
    label 'process_medium'

    debug false

    input:
    tuple val(meta), val(files)

    output:
    tuple val(meta), val("$params.publish_dir/03peak_macs2/${meta.sample}_${meta.control}/broad/${meta.sample}_peaks.broadPeak"), emit: broadPeak
    tuple val(meta), val("$params.publish_dir/03peak_macs2/${meta.sample}_${meta.control}/broad/${meta.sample}_peaks.gappedPeak"), emit: gappedPeak
    tuple val(meta), val("$params.publish_dir/03peak_macs2/${meta.sample}_${meta.control}/broad/${meta.sample}_peaks.xls"), emit: xls

    script:
    paired_end = meta.SE == "TRUE" ? "--format BAM --nomodel" : "--format BAMPE"

    """
    mkdir -p ${params.publish_dir}/00log/macs2

    macs2 callpeak ${paired_end} \
        --broad --broad-cutoff ${params.macs2_pvalue_broad} \
        --treatment ${files.target} \
        --control ${files.control} \
        --gsize ${params.macs2_gsize} \
        --outdir ${params.publish_dir}/03peak_macs2/${meta.sample}_${meta.control}/broad \
        --name ${meta.sample} \
        --pvalue ${params.macs2_pvalue_narrow} \
        ${params.macs2_params} 2> ${params.publish_dir}/00log/macs2/broad_macs2.log           
    """
}