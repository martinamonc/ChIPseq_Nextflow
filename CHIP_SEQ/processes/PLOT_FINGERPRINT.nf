process PLOT_FINGERPRINT {
    label 'process_low'

    debug true

    input:
    tuple val(meta), val(files)

    output:
    tuple val(meta), val("${dir}.qualityMetrics.tsv"), val("${dir}.rawcounts.tsv"), emit: metrics
    tuple val(meta), val("${dir}.plot.pdf"), emit: plot

    script:
    dir = "${params.publish_dir}/01qc/fingerPrint/${meta.sample}_${meta.control}" // this is just for tidyness purposes
    """
    mkdir -p ${params.publish_dir}/01qc/fingerPrint
    plotFingerprint -b ${files.target} ${files.control} \
    -p 1 \
    --outQualityMetrics ${dir}.qualityMetrics.tsv \
    --outRawCounts ${dir}.rawcounts.tsv \
    --plotFile ${dir}.plot.pdf
    """

}