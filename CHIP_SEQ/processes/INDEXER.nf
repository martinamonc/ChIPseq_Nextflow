process INDEXER {
    debug true
    label "process_high"

    input:
    val aligner_type

    output:
    val "$params.index_dir/$params.ref_name/$params.ref_name", emit: index

    script:
    if (aligner_type == "Bowtie") {
        """
        mkdir -p ${params.index_dir}/${params.ref_name}
        bowtie-build --threads 8 -f ${params.ref_input} ${params.index_dir}/${params.ref_name}/${params.ref_name}
        """
    } else if (aligner_type == "Bowtie2") {
        """
        mkdir -p ${params.index_dir}/${params.ref_name}
        bowtie2-build --threads 8 -f ${params.ref_input} ${params.index_dir}/${params.ref_name}/${params.ref_name}
        """
    }
}