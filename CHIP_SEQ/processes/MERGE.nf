process MERGE {
    // debug true

    input:
    tuple val(meta), val(reads)

    output:
    tuple val(meta), path("*.merged.fastq.gz"), emit: reads

    script: 
    def prefix = meta.sample
    def readList = reads instanceof List ? reads.collect{ it.toString() } : [reads.toString()]

    if (meta.SE) {
        if (readList.size >= 1) {
            """
            echo "CONCATENATING ${meta}, ${readList.join(' ')}"
            cat ${readList.join(' ')} > ${prefix}.merged.fastq.gz
            """
        }
    } else {
        if (readList.size >= 2) {
            def read1 = []
            def read2 = []
            readList.eachWithIndex{ v, ix -> ( ix & 1 ? read2 : read1 ) << v }
            """
            echo "CONCATENATING ${meta}, R1: ${read1.join(' ')}"
            cat ${read1.join(' ')} > ${prefix}_1.merged.fastq.gz
            echo "CONCATENATING  ${meta}, R2: ${read2.join(' ')}"
            cat ${read2.join(' ')} > ${prefix}_2.merged.fastq.gz
            """
        }
    }
}