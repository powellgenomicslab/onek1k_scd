#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Seurat normalization
# author: Jose Alquicira Hernandez
# date: 2021-12-02
# description: Performs scale factor normalization

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S norm
# qrsh -N norm -l mem_requested=100G
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("Seurat")
library("SeuratDisk")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- here("results", "2021-12-02_norm")
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
#   Normalize data                                                          ####

data <- NormalizeData(data)

#   ____________________________________________________________________________
#   Export data                                                             ####

SaveH5Seurat(data, filename = here(output, "onek1k.h5seurat"), overwrite = TRUE)

#   ____________________________________________________________________________
#   Session info                                                            ####

print_session(here(output))
