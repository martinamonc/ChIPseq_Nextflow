process CALL_PEAKS {
    label 'process_low'

    debug false

    input:
    tuple val(meta), val(files)

    output:
    tuple val(meta), val("$params.publish_dir/03peak_macs2/${meta.sample}_${meta.control}/${meta.sample}_peaks.narrowPeak"), val("$params.publish_dir/03peak_macs2/${meta.sample}_${meta.control}/${meta.sample}_summits.bed"), emit: narrowPeak
    tuple val(meta), val("$params.publish_dir/03peak_macs2/${meta.sample}_${meta.control}/${meta.sample}_peaks.xls"), emit: xls

    script:
    paired_end = meta.SE == "TRUE" ? "--format BAM --nomodel" : "--format BAMPE"

    """
    mkdir -p ${params.publish_dir}/00log/macs2

    macs2 callpeak ${paired_end} \
        --treatment ${files.target} \
        --control ${files.control} \
        --gsize ${params.macs2_gsize} \
        --outdir ${params.publish_dir}/03peak_macs2/${meta.sample}_${meta.control} \
        --name ${meta.sample} \
        --pvalue ${params.macs2_pvalue_narrow} \
        ${params.macs2_params} 2> ${params.publish_dir}/00log/macs2/${meta.sample}_${meta.control}_macs2.log            
    """
}