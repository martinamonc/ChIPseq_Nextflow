include { FASTQC                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/FASTQC.nf'
include { PHANTOM_PEAK_QUAL                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/PHANTOM_PEAK_QUAL.nf'
include { INSERT_SIZE                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/INSERT_SIZE.nf'
include { PLOT_FINGERPRINT                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/PLOT_FINGERPRINT.nf'
include { MULTIQC                   } from '/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ/processes/MULTIQC.nf'

workflow QC {
    
    take:
    ch_merge
    ch_final_al
    ch_tocall
    filtered
    excel
    alignlog
    alignduplog

    main:
    FASTQC( ch_merge )

    ch_final_al
    .map { 
        meta, file1, file2 ->
            meta = [sample:meta.sample, SE:meta.SE, control:meta.control, spike:meta.spike, is_input:meta.is_input, spike_control:meta.spike_control, genome:meta.genome] // do I really need to restate all the fields? or could I just include meta1 as is?
            bam = file1
        [meta, bam]
    }
    .set { bams4QC }

    PHANTOM_PEAK_QUAL( bams4QC.filter { it[0].is_input == "FALSE" } )
    
    INSERT_SIZE( bams4QC )

    PLOT_FINGERPRINT( ch_tocall )

    alignlog.collect{it[1]}.ifEmpty([])
    .mix ( FASTQC.out.collect{it[1]}.ifEmpty([]) )
    .mix ( INSERT_SIZE.out.txt.collect{it[1]}.ifEmpty([]) )
    .mix ( PHANTOM_PEAK_QUAL.out.collect{it[1]}.ifEmpty([]) )
    .mix ( alignduplog.collect{it[1]}.ifEmpty([]) )
    .mix ( PLOT_FINGERPRINT.out.metrics.collect{it[1]}.ifEmpty([]) )
    .mix ( PLOT_FINGERPRINT.out.metrics.collect{it[2]}.ifEmpty([]) )
    .mix ( excel.collect{it[1]}.ifEmpty([]) )
    .set { multiqc_input }

    multiqc_input_ch = multiqc_input
    .collectFile(name: 'multiqc_input.txt', newLine: true, storeDir: params.publish_dir + "/01qc/multiqc") { it -> it.join('\n') }
    .map { file -> file.path }

    MULTIQC( multiqc_input_ch )

    emit:
    FASTQC.out
    MULTIQC.out
}