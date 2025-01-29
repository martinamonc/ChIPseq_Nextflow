#!/bin/bash
#PBS -l walltime=24:00:00
#PBS -k oe
#PBS -N nextflow_run
#PBS -l select=1:ncpus=1:mem=8g
#PBS -m ae
#PBS -M martina.monciotti@ieo.it
 
# Usage --> workdir='/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ' ./execute_pipeline.sh (workdir is mandatory)
# if you're using qsub, you must use "-v" before "workdir=" to implement the environment variable
# workdir = the directory where the main.nf file is located

# Use the workdir environment variable
if [ -z "$workdir" ]; then
  echo "Usage: workdir=<workdir> ./execute_pipeline.sh"
  echo " 	<workdir> : Please specifiy a name for the working directory, e.g. .nextflow_chip"
  exit 1
fi

#workdir='/hpcnfs/scratch/DP/mmonciotti/CHIP_SEQ'

#mkdir -p $LOG_LOCATION
LOG_LOCATION=${workdir}/LOG
exec > $LOG_LOCATION/run.log 2>&1 #these 2 lines of code make it so that the log folder is created when the run.log file is

cd $workdir
 
#nextflow -h
nextflow run ${workdir}/main.nf -profile singularity,IEO_conf -resume

#-with-dag flowchart.png