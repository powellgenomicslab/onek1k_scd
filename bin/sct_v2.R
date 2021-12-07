#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Process data with SCTransform V2
# author: Jose Alquicira Hernandez
# date: 2021-11-30
# description: Applies V2 SCTransform to OneK1K data

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S sct_v2
# qrsh -N sct_v2 -l mem_requested=700G
# conda activate sct2

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("Seurat")
library("SeuratDisk")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- here("results", "2021-11-30_SCT_v2")
dir.create(output)

#   ____________________________________________________________________________
#   Import data                                                             ####

inicio("Read data")
data <- LoadH5Seurat(here( "results", "2021-11-10_add_metadata", "onek1k.h5seurat"), 
                     assays = list(RNA = "counts"))
Idents(data) <- "predicted.celltype.l2"
fin()

#   ____________________________________________________________________________
#   Remove outliers                                                         ####

data <- data[, !data$ethnic_outlier]

#   ____________________________________________________________________________
#   Apply SCTransform                                                       ####

inicio("Applying SCT")
data <- SCTransform(data, variable.features.n = 5000, vst.flavor = "v2", conserve.memory = TRUE)
fin()

#   ____________________________________________________________________________
#   Export data                                                             ####

SaveH5Seurat(data, filename = here(output, "onek1k.h5seurat"), overwrite = TRUE)

#   ____________________________________________________________________________
#   Session info                                                            ####

print_session(here(output))
