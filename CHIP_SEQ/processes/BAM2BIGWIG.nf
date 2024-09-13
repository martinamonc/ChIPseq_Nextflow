process BAM2BIGWIG {
    label 'process_medium'

    debug true

    input:
    tuple val(meta), val(files), val(cmds)

    output:
    tuple val(meta), val("$params.publish_dir/06bigwig/*.bw"), emit: bigwigs

    script:
    scr = cmds == "${params.ext_scripts}/bam2bigwig_spike_noSubtract.py" ? cmds + " --spike ${files.spike} --refmm ${files.ref_mm} --refdm ${files.ref_dm}" : cmds
    read_exten = meta.SE == "FALSE" ? "--extendReads" : "--extendReads ${params.read_extension}"

    """
    mkdir -p ${params.publish_dir}/00log/bam2bw
    mkdir -p ${params.publish_dir}/06bigwig

    python ${scr} \
    --target ${files.target} \
    --bigwig ${params.publish_dir}/06bigwig/${meta.sample}_${meta.spike_control}.bw \
    --threads ${params.threads} \
    --otherParams ${read_exten} ${params.b2b_other} &> ${params.publish_dir}/00log/bam2bw/${meta.sample}_${meta.spike_control}_B2B.log
    """
}