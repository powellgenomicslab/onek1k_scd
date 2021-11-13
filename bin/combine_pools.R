#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Combine pools
# author: Jose Alquicira Hernandez
# date: 2021-10-30
# description: Aggregates all 75 pools into a single Seurat Object

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S combine
# qrsh -N combine -l mem_requested=150G -pe smp 1 -q short.q
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("data.table")
library("Seurat")
library("stringr")
library("SeuratDisk")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- set_output("2021-10-30", "combine_pools")

#   ____________________________________________________________________________
#   Import data                                                             ####

path <- file.path("results", "2021-10-28_cell_type_annotation")

pool_dirs <- list.dirs(path, recursive = FALSE, full.names = FALSE)

pools <- lapply(pool_dirs, function(x){
  message("Reading ", x)
  readRDS(here(path, x, "query.RDS"))
})

names(pools) <- str_remove(pool_dirs, "_out$")

#   ____________________________________________________________________________
#   Merge pools                                                             ####

inicio("Merge pools")
data <- merge(pools[[1]], pools[-1], merge.dr = c("azimuth_spca", "azimuth_umap"))
fin()

# Relabel individual
data$individual[which(data$individual=="870_871" & data$pool=="pool_19")] <- "966_967"

#   ____________________________________________________________________________
#   Export data                                                             ####

SaveH5Seurat(data, filename = here(output, "onek1k.h5Seurat"), overwrite = TRUE)

#   ____________________________________________________________________________
#   Session info                                                            ####

print_session(here(output))
