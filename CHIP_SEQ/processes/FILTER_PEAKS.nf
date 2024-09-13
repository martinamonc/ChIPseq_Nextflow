process FILTER_PEAKS {
    label 'process_low'

    debug true

    input:
    tuple val(meta), val(narrowPeak), val(summit)

    output:
    tuple val(meta), val("${params.publish_dir}/03peak_macs2/${meta.sample}_${meta.control}/${meta.sample}_peaks_p${params.macs2_filt_peaks_pval}.bed"), emit: filt_bed
    tuple val(meta), val("${params.publish_dir}/03peak_macs2/${meta.sample}_${meta.control}/${meta.sample}_summits_p${params.macs2_filt_peaks_pval}.bed"), emit: filt_summit

    script:
    awk8 = '$8' + " >= ${params.macs2_filt_peaks_pval}"
    awk5 = '$5' + " >= ${params.macs2_filt_peaks_pval}"

    """
    awk '${awk8}' ${narrowPeak} | cut -f1-4,8 > ${params.publish_dir}/03peak_macs2/${meta.sample}_${meta.control}/${meta.sample}_peaks_p${params.macs2_filt_peaks_pval}.bed
    awk '${awk5}' ${summit} > ${params.publish_dir}/03peak_macs2/${meta.sample}_${meta.control}/${meta.sample}_summits_p${params.macs2_filt_peaks_pval}.bed
	"""
}