# onek1k_scd

Phase 2 analysis for OneK1K data in hg38 and new cell type annotation

## Create Seurat objects

-   input: /directflow/SCCGGroupShare/projects/data/experimental_data/CLEAN/OneK1K_scRNA/OneK1K_scRNA_V3
-   output: results/2021-10-26_raw_seurat_objects
-   script: [raw_seurat_object](https://github.com/powellgenomicslab/onek1k_scd/blob/36ae1095c65e3b1d5a25cf158bdc908ae65080aa/bin/raw_seurat_object.R)

This version creates a Seurat object for each pool and calculates the percentage of mitochondrial expression. Results are saved in separate `.RDS` objects.

------------------------------------------------------------------------

## Classify cells pre-QC

-   input: results/2021-10-26_raw_seurat_objects

-   output:

-   script:
