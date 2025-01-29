process SPIKE_INDEXER {
    debug true
    label "process_high"

    input:
    val aligner_type

    output:
    val "$params.spike_index_dir/$params.spike_ref_name", emit: index

    script:
    if (aligner_type == "Bowtie") {
        """
        mkdir -p ${params.spike_index_dir}
        bowtie-build --threads 8 -f ${params.spike_ref_input} ${params.spike_index_dir}/${params.spike_ref_name}
        """
    } else if (aligner_type == "Bowtie2") {
        // change threads back to 4
        """
        mkdir -p ${params.spike_index_dir}
        bowtie2-build --threads 8 -f ${params.spike_ref_input} ${params.spike_index_dir}/${params.spike_ref_name}
        """
    }
}