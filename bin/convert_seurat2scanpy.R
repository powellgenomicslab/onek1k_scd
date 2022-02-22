#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Convert onek1k data to h5ad file
# author: Jose Alquicira Hernandez
# date: 2021-11-10
# description: Converts onek1k data to h5ad file

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S h5ad
# qrsh -N h5ad -l mem_requested=350G
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("Seurat")
library("SeuratDisk")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- here("results", "2022-02-22_h5ad")
dir.create(output)

#   ____________________________________________________________________________
#   Import data                                                             ####

data <- LoadH5Seurat(here("results", "2021-11-10_add_metadata", "onek1k.h5seurat"),
                     assays = list(RNA = "counts"), 
                     reductions = c("umap", "harmony", "pca", "azimuth_spca", "azimuth_umap"))

#   ____________________________________________________________________________
#   Export data                                                             ####

SaveH5Seurat(data, filename = here(output, "onek1k.h5Seurat"), overwrite = TRUE)
Convert(here(output, "onek1k.h5Seurat"), dest = "h5ad", overwrite = TRUE)

#   ____________________________________________________________________________
#   Session info                                                            ####

print_session(here(output))





