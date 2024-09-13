process ALIGN {
    label 'process_high'

    debug true
    
    publishDir "${params.publish_dir}/02aln", mode:'copy', saveAs:{"${params.publish_dir}/02aln/${prefix}.bam"}

    input:
    tuple val(meta), val(reads)
    val index 
    val spike

    output:
    tuple val(meta), path("*.bam"), path("*.bai"), emit: bamis
    tuple val(meta), val("$params.publish_dir/00log/alignment/$prefix/${meta.sample}.log"), emit: log
    tuple val(meta), val(rm_dup_dir), emit: rm_dup_log

    script:
    prefix = spike == true ? "$meta.sample"+"_spike" : meta.sample 
    rm_dup_dir = meta.SE == true ? "" : "$params.publish_dir/00log/alignment/$prefix/rmdup/${meta.sample}.log"

    if (params.aligner == "Bowtie") {
        if (meta.SE == true) {    
            """
            # echo "Aligning ${prefix} with parameters: ${params.bowtie_global}"
            mkdir -p ${params.publish_dir}/00log/alignment/${prefix}

            bowtie -p ${params.align_threads} ${params.bowtie_global} -x ${index} ${reads} 2> ${params.publish_dir}/00log/alignment/${prefix}/${meta.sample}.log \
            | samtools view -b -F 4 - \
            | samtools sort -m ${params.samtools_mem}G -T ${prefix}.bam -o ${prefix}.bam - 2>> ${params.publish_dir}/00log/alignment/${prefix}/${meta.sample}.log
            
            samtools index ${prefix}.bam
            """
        } else {
            """
            # echo "Aligning ${prefix} with parameters: ${params.bowtie_global} ${params.bowtie_pe}"
            mkdir -p ${params.publish_dir}/00log/alignment/${prefix}
            mkdir -p ${params.publish_dir}/00log/alignment/${prefix}/rmdup

            bowtie -p ${params.align_threads} ${params.bowtie_global} ${params.bowtie_pe} -x ${index} -1 ${reads[0]} -2 ${reads[1]}  2> ${params.publish_dir}/00log/alignment/${prefix}/${meta.sample}.log \
            | samblaster --removeDups 2> ${params.publish_dir}/00log/alignment/${prefix}/rmdup/${meta.sample}.log \
            | samtools view -b -F 4 - \
            | samtools sort -m ${params.samtools_mem}G -T ${prefix}.bam -o ${prefix}.bam - 2>> ${params.publish_dir}/00log/alignment/${prefix}/${meta.sample}.log
            
            samtools index ${prefix}.bam
            # echo "Finished aligning ${prefix}. Output log files: ${params.publish_dir}/00log/alignment/${prefix}/${meta.sample}.log and ${params.publish_dir}/00log/alignment/${prefix}/rmdup/${meta.sample}.log"
            """
        }
    } else if (params.aligner == "Bowtie2") {
        if (meta.SE == true) {    
            """
            # echo "Aligning ${prefix} with parameters: ${params.bowtie2_global}"
            mkdir -p ${params.publish_dir}/00log/alignment/${prefix}

            bowtie2 -p ${params.align_threads} ${params.bowtie2_global} -x ${index} ${reads} 2> ${params.publish_dir}/00log/alignment/${prefix}/${meta.sample}.log \
            | samtools view -b -F 4 - \
            | samtools sort -m ${params.samtools_mem}G -T ${prefix}.bam -o ${prefix}.bam - 2>> ${params.publish_dir}/00log/alignment/${prefix}/${meta.sample}.log
            
            samtools index ${prefix}.bam
            """
        } else {
            """
            # echo "Aligning ${prefix} with parameters: ${params.bowtie2_global} ${params.bowtie2_pe}"
            mkdir -p ${params.publish_dir}/00log/alignment/${prefix}
            mkdir -p ${params.publish_dir}/00log/alignment/${prefix}/rmdup

            bowtie2 -p ${params.align_threads} ${params.bowtie2_global} ${params.bowtie2_pe} -x ${index} -1 ${reads[0]} -2 ${reads[1]}  2> ${params.publish_dir}/00log/alignment/${prefix}/${meta.sample}.log \
            | samblaster --removeDups 2> ${params.publish_dir}/00log/alignment/${prefix}/rmdup/${meta.sample}.log \
            | samtools view -b -F 4 - \
            | samtools sort -m ${params.samtools_mem}G -T ${prefix}.bam -o ${prefix}.bam - 2>> ${params.publish_dir}/00log/alignment/${prefix}/${meta.sample}.log
            
            samtools index ${prefix}.bam
            # echo "Finished aligning ${prefix}. Output log files: ${params.publish_dir}/00log/alignment/${prefix}/${meta.sample}.log and ${params.publish_dir}/00log/alignment/${prefix}/rmdup/${meta.sample}.log"
            """
        }
    } else {
        error "Error: please pick an aligner between ['Bowtie', 'Bowtie2'] and specify it in the config params."
    }
}