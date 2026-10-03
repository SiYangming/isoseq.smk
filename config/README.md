## Workflow overview

PacBio Iso-Seq: CCS, lima, isoseq3 refine, bamtools convert, TAMA polyA cleanup, minimap2 or uLTRA, TAMA collapse/merge. Optional Picard SplitSamByNumberOfReads for lima/refine/bamtools entrypoints.

## Input data

Sample sheet (`config/samples.tsv`):

| sample | bam | pbi | reads |
| ------ | --- | --- | ----- |
| alz    | path/to/sample.subreads.bam | optional pbi | FASTA/FASTQ for map |

Also set `primers`, `fasta`, and (for ultra) `gtf` in `config/config.yaml`.

Minimal test files: `bash .test/fetch_testdata.sh` (nf-core/test-datasets isoseq branch).
