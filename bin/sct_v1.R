#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Process data with SCTransform
# author: Jose Alquicira Hernandez
# date: 2021-11-30
# description: Applies V1 SCTransform to OneK1K data

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S sct_v1
# qrsh -N sct_v1 -l mem_requested=250G -pe smp 3 -q short.q
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("Seurat")
library("SeuratDisk")
library("future")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- here("results", "2021-11-30_SCT_v1")
dir.create(output)

#   ____________________________________________________________________________
#   Define future                                                           ####

options(future.globals.maxSize = Inf * 1024^3)
plan("multisession", workers = 3)
plan("sequential")

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
data <- SCTransform(data, variable.features.n = 5000, conserve.memory = TRUE)
fin()

#   ____________________________________________________________________________
#   Export data                                                             ####

SaveH5Seurat(data, filename = here(output, "onek1k.h5seurat"), overwrite = TRUE)

#   ____________________________________________________________________________
#   Session info                                                            ####

print_session(here(output))