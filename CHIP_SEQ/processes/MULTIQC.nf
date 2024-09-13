process MULTIQC {
    label 'process_low'

    debug true

    input:
    val multiqc_input_ch

    output:
    val("${params.publish_dir}/01qc/multiqc/multiqc_report.html")

    script:
    """
    mkdir -p ${params.publish_dir}/01qc/multiqc
    mkdir -p ${params.publish_dir}/00log/multiqc
    multiqc -o ${params.publish_dir}/01qc/multiqc --file-list "${params.publish_dir}/01qc/multiqc/multiqc_input.txt" -f -v -n "multiqc_report" 2> ${params.publish_dir}/00log/multiqc/multiqc.log
    """

}