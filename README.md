# onek1k_scd

Phase 2 analysis for OneK1K data in hg38 and new cell type annotation

## Create Seurat objects

-   input: /directflow/SCCGGroupShare/projects/data/experimental_data/CLEAN/OneK1K_scRNA/OneK1K_scRNA_V3
-   output: results/2021-10-26_raw_seurat_objects
-   script: [raw_seurat_object.R](https://github.com/powellgenomicslab/onek1k_scd/blob/45e72279d3032c9ea2251e3ff9005c69de3a4527/bin/raw_seurat_object.R "45e7227")

This version creates a Seurat object for each pool and calculates the percentage of mitochondrial expression. Results are saved in separate `.RDS` objects. Pool number is appended to each barcode to avoid duplicates when pools are combined.


## Classify cells pre-QC

-   input: results/2021-10-26_raw_seurat_objects
-   output: results/2021-10-26_pre-qc_annotation
-   script: [pre-qc_annotate.qsub.sh](https://github.com/powellgenomicslab/onek1k_scd/blob/d3c4415d7036198ba384ef7862a3b85e1ff5b599/bin/pre-qc_annotate.qsub.sh "d3c4415")
    -   <https://github.com/sc-eQTLgen-consortium/WG2-pipeline-classification/tree/c30cd57cca5c0bf17e587b8abb53ce5380f0a709>

## Aggregate metadata pre-QC

- input: results/2021-10-26_pre-qc_annotation
- output: results/2021-10-26_pre-qc_metadata_aggregation
- script: [pre-qc_metadata_aggregation.R](https://github.com/powellgenomicslab/onek1k_scd/blob/32a8b61939231b51a10231c7e9ac199ff2906d08/bin/pre-qc_metadata_aggregation.R "32a8b61")

## Perform QC

- input: results/2021-10-26_pre-qc_metadata_aggregation
- output: results/2021-10-28_qc_filter_barcodes
- script: [QC.R](https://github.com/powellgenomicslab/onek1k_scd/blob/c1987d5baf8ad3db6d0e28ab60d6e54edebcd496/bin/QC.R "c1987d5")

## Filter barcodes

- input: 
  + results/2021-10-28_qc_filter_barcodes
  + results/2021-10-26_pre-qc_annotation
- output: results/2021-10-28_cleaned_barcodes
- script: [clean_barcodes.R](https://github.com/powellgenomicslab/onek1k_scd/blob/8abca650c71fe75898f5c43371a8741475ef9dcb/bin/clean_barcodes.R "8abca65")


## Cell type classification

- input: results/2021-10-28_cleaned_barcodes
- output: results/2021-10-28_cell_type_annotation
- script: [cell_type_annotation.sh](https://github.com/powellgenomicslab/onek1k_scd/blob/b1fd2b2b4f4fd55b75de5faa3eb6d622fef4f39f/bin/cell_type_annotation.sh "b1fd2b2")


## Combine pools

- input: results/2021-10-28_cell_type_annotation
- output: results/2021-10-30_combine_pools
- script: [combine_pools.sh](https://github.com/powellgenomicslab/onek1k_scd/blob/9ee53f3d8ec7b48a029237233fef4ccb4bfaba04/bin/combine_pools.R "9ee53f3")


## Align pools

- input: results/2021-10-30_combine_pools
- output: results/2021-10-30_aligned_data
- script: [align_embeddings.R](https://github.com/powellgenomicslab/onek1k_scd/blob/73389dce67c99dc27d59efd186d01a9113d911a6/bin/align_embeddings.R "73389dc")

## Add metadata

- input: results/2021-10-30_aligned_data
- output: results/2021-11-10_add_metadata
- script: [add_sex_age.R](https://github.com/powellgenomicslab/onek1k_scd/blob/9d8a8863c9c5973c001bef31f5dd77c5c0c78ce4/bin/add_sex_age.R "9d8a886")

This step also adds ancestry information

## Convert Seurat to Scanpy

- input: results/2021-11-10_add_metadata
- output: results/2021-11-10_h5ad
- script: [convert_seurat2scanpy.R](https://github.com/powellgenomicslab/onek1k_scd/blob/ef3e6cc3dfc53896cd38c991a9affd52831737f2/bin/convert_seurat2scanpy.R "ef3e6cc")

Stores raw counts, azimuth reductions, and harmony embeddings


## Apply SCTransform v1

- input: results/2021-11-10_add_metadata
- output: results/2021-11-30_SCT_v1
- script: [sct_v1.R](https://github.com/powellgenomicslab/onek1k_scd/blob/b5dad00c45c94a7871b4e1bd3bb2e03aed63183e/bin/sct_v1.R "b5dad00")

## Apply SCTransform v2

- input: results/2021-11-10_add_metadata
- output: results/2021-11-30_SCT_v2
- script: [sct_v1.R](https://github.com/powellgenomicslab/onek1k_scd/blob/04cc3b1db9893148471433c7f534c1918c81623c/bin/sct_v2.R "04cc3b1")


## Apply scale factor normalization

- input: results/2021-11-10_add_metadata
- output: results/2021-12-02_norm
- script: [norm.R](https://github.com/powellgenomicslab/onek1k_scd/blob/e3464910137c596632271e4eb957bb0039c05320/bin/norm.R "e346491")
