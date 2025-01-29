process FASTQC {
    label 'process_low'

    debug false

    input:
    tuple val(meta), val(files)

    output:
    tuple val(meta), val("${params.publish_dir}/01qc/fqc/${meta.sample}_fastqc.zip")

    script:
    fastq1 = files[0]
    newname = "${meta.sample}.fastq.gz"
    
    """
    mkdir -p ${params.publish_dir}/01qc/fqc
    mkdir -p ${params.publish_dir}/00log/fqc

    cd ${params.publish_dir}/01qc/fqc # Move to folder where symlink is going to be created
    ln -sf ${fastq1} ${newname} # Create symlink to fastq file. Imporant to set the desired file name. 
    cd - # Go back to workdir
    fastqc -o ${params.publish_dir}/01qc/fqc -f fastq -t 6 --noextract ${params.publish_dir}/01qc/fqc/${newname} 2> ${params.publish_dir}/00log/fqc/${meta.sample}.log
    """

}