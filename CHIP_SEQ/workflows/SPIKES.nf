include { MERGE                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/MERGE.nf'
include { ALIGN                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/ALIGN.nf'
include { SPIKE_INDEXER                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/SPIKE_INDEXER.nf'
include { CLEAN_SPIKE                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/CLEAN_SPIKE.nf'
include { BAM2BIGWIG                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/BAM2BIGWIG.nf'

workflow SPIKES {

    take:
    spike_files
    all_aligned

    main:
    if (params.spike_index_exists == true) {
        spike_index = params.aligner == "Bowtie" ? params.spike_bowtie_index : params.spike_bowtie2_index
    } else {
        spike_index = SPIKE_INDEXER(params.aligner).index
    }

    ALIGN(spike_files, spike_index, true)
    .bamis
    .set { spiked_aligned }
    
    // this channel takes all alignments (spike and non) and prepares their bam + bai files for the cleaning process
    spiked_aligned
    .join(all_aligned) // this is a left join, so this channel creation already excludes all those samples where spike=FALSE as they won't be in spiked_aligned
    .map { sample->
        def meta = sample[0]
        def files = [sample[1], sample[3], sample[2], sample[4]]
        [meta, files]
    }
    .set { ch_toclean }

    CLEAN_SPIKE( ch_toclean )
    .set {ch_cleaned}

    ch_cleaned
    .mix(all_aligned.filter { it[0].spike == 'FALSE' })
    .set {ch_final_al}

    ch_final_al
    .filter { it[0].spike == "FALSE" }
    .map { 
        meta, bam, bai ->
            files = [target:bam]
            cmds = "${params.ext_scripts}/bam2bigwig_noSubtract.py"
        [meta, files, cmds]
    }
    .filter { it[0].sample != it[0].control }
    .set { ch_1 }

    ch_final_al
    .filter { it[0].spike == "TRUE" }
    .combine(ch_final_al)
    .map { 
        meta1, bam1, spike_bam1, meta2, bam2, spike_bam2 ->
            meta = [sample:meta1.sample, SE:meta1.SE, control:meta1.control, spike:meta1.spike, is_input:meta1.is_input, spike_control:meta1.spike_control, genome:meta1.genome]
            files = meta1.spike_control == meta2.sample ? [ target:bam1, spike:spike_bam1, ref_mm:bam2, ref_dm:spike_bam2 ] : null
            cmds = "${params.ext_scripts}/bam2bigwig_spike_noSubtract.py"
        [meta, files, cmds]
    }
    .filter { it[1] != null }
    .filter { it[0].sample != it[0].spike_control }
    .set { ch_2 }

    ch_1
    .mix(ch_2)
    .set { ch_toB2B }

    BAM2BIGWIG(ch_toB2B)
    .set { ch_postB2B }

    emit:
    ch_final_al
} 