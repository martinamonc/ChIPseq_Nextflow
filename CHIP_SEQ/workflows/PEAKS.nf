include { CALL_PEAKS                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/CALL_PEAKS.nf'
include { CALL_BROADPEAKS                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/CALL_BROADPEAKS.nf'
include { FILTER_PEAKS                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/FILTER_PEAKS.nf'
include { ANNOTATE_PEAKS                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/ANNOTATE_PEAKS.nf'

workflow PEAKS {
    
    take:
    ch_final_al

    main:

    ch_final_al
    .combine(ch_final_al)
    .map { 
        meta1, bam1, spike_bam1, meta2, bam2, spike_bam2 ->
            meta = [sample:meta1.sample, SE:meta1.SE, control:meta1.control, spike:meta1.spike, is_input:meta1.is_input, spike_control:meta1.spike_control, genome:meta1.genome]
            files = meta1.control == meta2.sample ? [ target:bam1, control:bam2 ] : null
        [meta, files]
    }
    .filter { it[1] != null }
    .filter { it[0].is_input == "FALSE" }
    .set { ch_tocall }
    
    CALL_PEAKS(ch_tocall)
    .set { narrow_peaks }

    CALL_BROADPEAKS(ch_tocall)
    .set { broad_peaks }

    // only filtering narrow peaks, no need for broad peaks
    FILTER_PEAKS(narrow_peaks.narrowPeak)
    .set { filtered_peaks }
    
    ANNOTATE_PEAKS( filtered_peaks.filt_bed )
    .set { annotated_peaks }

    emit:
    ch_tocall
    broad_peaks.broadPeak
    broad_peaks.gappedPeak
    filtered = filtered_peaks.filt_bed
    filtered_peaks.filt_summit
    annotated_peaks.other
    excel = narrow_peaks.xls
}