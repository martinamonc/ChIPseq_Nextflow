process INSERT_SIZE {
    label 'process_low'

    debug false

    input:
    tuple val(meta), val(bam)

    output:
    tuple val(meta), val(out1), emit: txt
    tuple val(meta), val(out2), emit: pdf

    script:
    out1 = "${params.publish_dir}/01qc/insert_size/${meta.sample}.isize.txt"
    out2 = "${params.publish_dir}/01qc/insert_size/${meta.sample}.isize.pdf"
    """
    mkdir -p ${params.publish_dir}/01qc/insert_size
    mkdir -p ${params.publish_dir}/00log/picard/insert_size
    touch ${out1} ${out2}
    picard CollectInsertSizeMetrics VALIDATION_STRINGENCY=LENIENT METRIC_ACCUMULATION_LEVEL=null METRIC_ACCUMULATION_LEVEL=SAMPLE \
    INPUT=${bam} OUTPUT=${out1} \
    HISTOGRAM_FILE=${out2} > ${params.publish_dir}/00log/picard/insert_size/${meta.sample}_isize.log
    """

}