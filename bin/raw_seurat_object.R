#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Create Seurat objects
# author: Jose Alquicira Hernandez
# date: 2021-10-26
# description: Set up Seurat object for each pool from the OneK1K data

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S obj
# qrsh -N obj -l mem_requested=200G -pe smp 1 -q short.q
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("data.table")
library("Seurat")
library("stringr")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- set_output("2021-10-26", "raw_seurat_objects")

#   ____________________________________________________________________________
#   Import data                                                             ####

path <- "/directflow/SCCGGroupShare/projects/data/experimental_data/CLEAN/OneK1K_scRNA/OneK1K_scRNA_V3"

pools_filenames <- list.dirs(path, recursive = FALSE, full.names = FALSE)

mats <- lapply(pools_filenames, function(pool){
  Read10X(file.path(path, pool, "outs", "filtered_feature_bc_matrix"))
})

#   ____________________________________________________________________________
#   Create Seurat object for each pool                                      ####

# Relabel pools
pool_names <- str_remove(pools_filenames, "OneK1K_scRNA_")
pool_names <- str_replace(pool_names, "Sample", "pool_")
names(mats) <- pool_names

# Create objects and calculate% of mitochondrial expression
objs <- mapply(function(m, pool){
  md <- data.frame(pool = rep(pool, ncol(m)), row.names =  colnames(m))
  x <- CreateSeuratObject(m, project = "onek1k", meta.data = md)
  x[["percent.mt"]] <- PercentageFeatureSet(x, pattern = "^MT-")
  x
}, mats, names(mats))


#   ____________________________________________________________________________
#   Export data                                                             ####

void <- mapply(function(obj, pool){
  message("Saving object ", pool)
  saveRDS(obj, file = here(output, pool %p% ".RDS"))
}, objs, names(objs))

#   ____________________________________________________________________________
#   Session info                                                            ####

print_session(here(output))