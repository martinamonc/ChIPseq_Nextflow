# ChIPseq_Nextflow - Pasini's lab ChIP-seq Nextflow pipeline

This is a Nextflow pipeline to be run specifically on our PBS-based HPC. All the softwares used were taken from [this](https://hub.docker.com/layers/andreamariani/chipseq_snakemake/101122/images/sha256-9d5848ad1a967dea579cf935ca6c84e381bbf62c2ea63a1a5dc2feb177f6a2f1?context=explore) singularity image.

## Set-up

### Raw data

The raw data paths should be located in the file specified in the `samplesheet` parameter within the `nextflow.config` file (`params.samplesheet`). The file should have the following structure:

| sample | control | spike | is_input | spike_control | genome | lane | fq1 | fq2 |
|----------|----------|----------|----------|----------|----------|----------|----------|----------|
| WT_Input   | WT_Input   | FALSE   | TRUE   | NOSPIKE   | mm10   | 1 | path/to/R1   | path/to/R2   |

with the paths in the last two columns and all the metadata in the columns preceeding them.
* **sample**: sample name
* **control**: control name
* **spike**: TRUE if the sample has been spiked or FALSE if it hasn't
* **is_input**: TRUE if the sample is to be used as a ChIP input or FALSE if it isn't, TRUE also for inputs sequenced just to alculate the ratio sample : spike-in, which won't be used to call peaks
* **spike_control**: the name of the sample to be used as control for the spike normalization, NOSPIKE if **spike** = FALSE
* **genome**: genome 
* **lane**: sample lane number
* **fq1**: path to sample R1 FASTA file 
* **fq2**: path to sample R2 FASTA file


### Parameter configuration

The user must specify their preferences for pipeline execution in the `params` section of the `nextflow.config` file. There are some fields that must be inevitably defined by the user as they depend on the user's directory organization, while the other ones deal with memory allocation and process-specific parameters, for which the user can use the default settings.

### Profiles

The `nextflow.config` file also contains the `profiles` section, where the user can specify their preferred profiles settings or add a new profile. The file contains the singularity profile and the IEO_conf profile (defined in its own `IEO_conf.config` file) by default, both used by the pipeline creator. The user can leave the default profile settings as they are or change them as they wish. Any new profile that isn't the singularity one should be implemented like the IEO_conf one: defined in its own .config file and mentioned in the `execute_pipeline.sh` script.

### Alignment index

The aligner index to be used should be indicated in the `nextflow.config` file. If you have no index, the pipeline can create one for you: just change `index_exists` to `false`, provide a comma-separated list of FASTA files containing the reference sequences needed with `ref_input` and specify assembly version with `ref_name`. For efficiency and storage-saving purposes, before creating a new index please make sure you haven't already created one in the index_dir directory in a previous run. If you have, then the `index_exists` parameter should be `true` and the `ref_input` parameter should be `index_dir/ref_name`.

## Pipeline execution

After filling out all the necessary configuration parameters, the user can run the pipeline by executing the `execute_pipeline` script like so:

```bash
workdir=<workdir> ./execute_pipeline.sh
```

If they want to run it with `qsub` by sending a job on a PBS-based HPC they must specify the work directory with the `-v` flag (for environment variables)

```bash
qsub -v workdir=<workdir> ./execute_pipeline.sh
```

## After the execution

### Clean-up

Once you're done running the pipeline, you can run the command `nextflow clean -f` inside the working directory (the `workdir` you specified at the beginning of the execution) and it will delete all the folders in the **work** folder created by Nextflow during your last run. If you want to delete folders relative to multiple different runs you can just run the same command multiple times. However, after cleaning the work folder you will lose all caches and temporary files so you won't be able to use the `-resume` feature and the pipeline will be run all over again.

The folders the user wants to keep long-term will be copied into the final results directory, which they have to specify in the `nextflow.config` file. All the ones in the `publish_dir` will be deleted eventually.
