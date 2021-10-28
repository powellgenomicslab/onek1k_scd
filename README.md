# onek1k_scd

Phase 2 analysis for OneK1K data in hg38 and new cell type annotation

## Create Seurat objects

-   input: /directflow/SCCGGroupShare/projects/data/experimental_data/CLEAN/OneK1K_scRNA/OneK1K_scRNA_V3
-   output: results/2021-10-26_raw_seurat_objects
-   script: [raw_seurat_object](https://github.com/powellgenomicslab/onek1k_scd/blob/45e72279d3032c9ea2251e3ff9005c69de3a4527/bin/raw_seurat_object.R "45e7227")

This version creates a Seurat object for each pool and calculates the percentage of mitochondrial expression. Results are saved in separate `.RDS` objects. Pool number is appended to each barcode to avoid duplicates when pools are combined.


## Classify cells pre-QC

-   input: results/2021-10-26_raw_seurat_objects
-   output: results/2021-10-26_pre-qc_annotation
-   script: [pre-qc_annotate.qsub.sh](https://github.com/powellgenomicslab/onek1k_scd/blob/d3c4415d7036198ba384ef7862a3b85e1ff5b599/bin/pre-qc_annotate.qsub.sh "d3c4415")
    -   <https://github.com/sc-eQTLgen-consortium/WG2-pipeline-classification/tree/c30cd57cca5c0bf17e587b8abb53ce5380f0a709>

## Aggregate metadata pre-QC

- input: results/2021-10-26_pre-qc_annotation
- output: results/2021-10-26_pre-qc_metadata_aggregation
- script: [pre-qc_metadata_aggregation](https://github.com/powellgenomicslab/onek1k_scd/blob/32a8b61939231b51a10231c7e9ac199ff2906d08/bin/pre-qc_metadata_aggregation.R "32a8b61")

## Perform QC

- input: results/2021-10-26_pre-qc_metadata_aggregation
- output: results/2021-10-28_qc_filter_barcodes
- script: [QC.R](https://github.com/powellgenomicslab/onek1k_scd/blob/c1987d5baf8ad3db6d0e28ab60d6e54edebcd496/bin/QC.R "c1987d5")

## Filter barcodes

- input: 
  + results/2021-10-28_qc_filter_barcodes
  + results/2021-10-26_pre-qc_annotation
- output: results/2021-10-28_cleaned_barcodes
- script: [clean_barcodes.R](https://github.com/powellgenomicslab/onek1k_scd/blob/4c1661834289aaa0f92205a86b6cb54e67905805/bin/clean_barcodes.R "4c16618")


