include { MERGE                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/MERGE.nf'
include { ALIGN                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/ALIGN.nf'
include { INDEXER                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/INDEXER.nf'
include { SPIKES                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/workflows/SPIKES.nf'
include { PEAKS                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/workflows/PEAKS.nf'
include { QC                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/workflows/QC.nf'

workflow {

    // create input channel from filename contained in INPUT parameter
    Channel
    .fromPath(params.samplesheet) 
    .splitCsv(header:false, sep:"\t", skip:1)
    .map { row ->
        def sample = row[0]
        def control = row[1]
        def spike = row[2]
        def is_input = row[3]
        def spike_control = row[4]
        def genome = row[5]
        // def lane = row[6]
        def fq1 = row[7]
        def fq2 = row[8]
        if (fq2 == null) {
            meta = [sample:sample, SE:true, control:control, spike:spike, is_input:is_input, spike_control:spike_control, genome:genome]
        } else {
            meta = [sample:sample, SE:false, control:control, spike:spike, is_input:is_input, spike_control:spike_control, genome:genome]
            fastqs = [fq1, fq2]
        }
        [meta, fastqs]
    }
    .groupTuple()
    .branch {
        meta, fastqs ->
            single: fastqs.size() == 1
                return [ meta, fastqs.flatten() ]
            multiple: fastqs.size() > 1
                return [ meta, fastqs.flatten() ]
    }
    .set {ch_fastq}

    // concatenate fastq files belonging to the same sample
    MERGE(ch_fastq.multiple)
    .reads
    .mix(ch_fastq.single)
    .set { ch_merge }

    if (params.index_exists == true) {
        index = params.aligner == "Bowtie" ? params.bowtie_index : params.bowtie2_index
    } else {
        index = INDEXER(params.aligner).index
    }

    // perform sequence alignment using aligner specified in params
    ALIGN( ch_merge, index, false )
    .bamis
    .set { ch_align }

    ch_merge.branch {
        spike: it[0].spike == "TRUE"
        not_spike: it[0].spike == "FALSE"
    }
    .set { spiked_ch_merge }

    SPIKES(
        spiked_ch_merge.spike, ch_align
    )

    PEAKS( SPIKES.out.ch_final_al )

    QC( ch_merge, SPIKES.out.ch_final_al, PEAKS.out.ch_tocall, PEAKS.out.filtered, PEAKS.out.excel, ALIGN.out.log, ALIGN.out.rm_dup_log )

}

def resultsDir = params.publish_dir
def dirsToKeep = params.dirsToKeep  // List of specific directories to copy
def finalDir = params.final_dir

// this below gets executed even when you terminate execution (success = false)
workflow.onComplete {
    
    def success = workflow.success

    if (resultsDir && dirsToKeep) {
        println "Executing cleanup commands"
        println "success: ${success}"

        // Convert list of directories to keep to a space-separated string
        def dirsToKeepString = dirsToKeep.join(' ')
        println "dirsToKeepString: ${dirsToKeepString}"

        def process = ["bash", "-c", """
        set -ex
        if [[ '${success}' == 'true' ]]; then
            # Debug: print the results directory and directories to keep
            echo "Results Directory: ${resultsDir}"
            echo "Directories to keep: ${dirsToKeepString}"

            find ${resultsDir} -mindepth 1 -maxdepth 1 -type d | while read dir; do
                keep=false
                for keepDir in ${dirsToKeepString}; do
                    echo "Checking directory: \$dir against \$keepDir"
                    if [[ \$(basename \"\$dir\") == \"\$keepDir\" ]]; then
                        cp -R \"\$dir\" ${finalDir}
                    fi
                done
            done

            # nextflow clean

        else
            echo "workflow_success is false!"
        fi
        """].execute()

        // Wait for the process to complete and check the exit value
        process.waitFor()
        if (process.exitValue() != 0) {
            println "Cleanup script failed with exit value ${process.exitValue()}"
            println process.err.text
        } else {
            println "Cleanup script completed successfully"
        }
    }
}