# Changelog

## [1.0.0](https://github.com/SiYangming/isoseq.smk/releases/tag/v1.0.0) (2026-10-05)

First release of the PacBio Iso-Seq Snakemake workflow (CCS → lima → refine → FLNC → align → TAMA), matching [SiYangming/isoseq.nf](https://github.com/SiYangming/isoseq.nf).

### Features

* End-to-end Iso-Seq: pbccs, lima, isoseq3 refine, bamtools convert, TAMA polyA cleanup, minimap2 or uLTRA, TAMA collapse/merge
* `exec_mode`: native, conda, docker, apptainer
* `entrypoint`: isoseq, lima, isoseq3_refine, bamtools_convert, map
* Optional Picard SplitSamByNumberOfReads for lima/refine/bamtools entrypoints
* Test data from [nf-core/test-datasets isoseq](https://github.com/nf-core/test-datasets/tree/isoseq); CI Tests (format, lint, workflow) pass

### Notes

* FLAIR is not part of this workflow (belongs in nanoseq)
