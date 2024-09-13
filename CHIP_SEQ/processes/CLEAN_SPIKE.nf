process CLEAN_SPIKE {

    input:
    tuple val(meta), val(files)

    output: 
    tuple val(meta), val("$params.publish_dir/02aln/$mmbam"), val("$params.publish_dir/02aln/$spikebam"), emit: clean_bams

    script:
    fileList = files instanceof List ? files.collect{ it.toString() } : [files.toString()]
    spikebam = meta.sample + "_spike.bam"
    mmbam = meta.sample + ".bam"
    meta = meta
    """
    python ${params.ext_scripts}/remove_spikeDups.py ${fileList.join(' ')} &> cleaning.log      

    mv ${fileList[0]}.temporary ${params.publish_dir}/02aln/${spikebam}
    mv ${fileList[1]}.temporary ${params.publish_dir}/02aln/${mmbam}

    samtools index ${params.publish_dir}/02aln/${spikebam}
    samtools index ${params.publish_dir}/02aln/${mmbam}
    """
} 