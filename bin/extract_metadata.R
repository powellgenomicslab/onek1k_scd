#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Extract metadata
# author: Jose Alquicira Hernandez
# date: 2022-02-22
# description: Extracts metadata from Seurat object. This metadata contains all 
# cells after QC and sample metadata

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S extract_md
# qrsh -N extract_md -l mem_requested=300G
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("Seurat")
library("SeuratDisk")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- here("results", "2022-02-22_final_metadata")
dir.create(output)

#   ____________________________________________________________________________
#   Import data                                                             ####

path <- "results/2021-11-10_add_metadata"
data <- LoadH5Seurat(here(path, "onek1k.h5seurat"), assays = list(RNA = "counts"), reductions = FALSE, graphs = FALSE, neighbors = FALSE)

#   ____________________________________________________________________________
#   Save results                                                            ####

saveRDS(data[[]], file = here(output, "metadata.RDS"))
