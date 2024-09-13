process ANNOTATE_PEAKS {
    label 'process_low'

    debug true

    input:
    tuple val(meta), val(filt_bed)

    output:
    tuple val(meta), val("*.annot"), emit: annotated
    tuple val(meta), val("*_promoTargets.bed"), val("*_promoTargets.txt"), val("*_promoPeaks.bed"), val("*_distalPeaks.bed"), emit: other

    script:
    paired_end = meta.SE == "TRUE" ? "--format BAM --nomodel" : "--format BAMPE"
    dirs = "$params.publish_dir/04peak_annot/${meta.sample}_${meta.control}/${meta.sample}_peaks_p$params.macs2_filt_peaks_pval"

    """
    mkdir -p ${params.publish_dir}/04peak_annot/${meta.sample}_${meta.control}
    Rscript --vanilla ${params.ext_scripts}/PeakAnnot.R ${filt_bed} ${params.bTSS} ${params.aTSS}   \
        ${dirs}.annot ${dirs}_promoTargets.bed ${dirs}_promoTargets.txt ${dirs}_promoPeaks.bed ${dirs}_distalPeaks.bed ${meta.genome}
    """
}
