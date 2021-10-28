#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Extract high quality cells
# author: Jose Alquicira Hernandez
# date: 2021-10-28
# description: For each pool, we extract the high quality droplets determined by
# doublet detection and QC

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S qc
# qrsh -N qc -l mem_requested=100G -pe smp 1 -q short.q
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("data.table")
library("Seurat")
library("stringr")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- set_output("2021-10-28", "cleaned_barcodes")

#   ____________________________________________________________________________
#   Import data                                                             ####

md <- readRDS(here("results", "2021-10-28_qc_filter_barcodes", "QC.RDS"))

path <- file.path("results", "2021-10-26_pre-qc_annotation")

pool_dirs <- list.dirs(path, recursive = FALSE, full.names = FALSE)

pools <- lapply(pool_dirs, function(x){
  message("Reading ", x)
  readRDS(here(path, x, "query.RDS"))
})

names(pools) <- str_remove(pool_dirs, "_out$")

#   ____________________________________________________________________________
#   Subset barcodes                                                         ####

filter_pool <- function(x){
  # Extract cells included in reference metadata
  i <- colnames(x) %chin% md$barcode
  if(all(!i)){
    message("Pool ", unique(x$pool), " skipped")
    return(NA)
  }
  x <- x[, i]
  # Extract metadata correspinding to current pool
  x_md <- md[barcode %chin% colnames(x)]
  
  # Extract variables of interest
  barcodes <- x_md$barcode
  x_md <- x_md[, .(individual, pool_number)]
  
  # Set up dataframe
  x_md <- as.data.frame(x_md)
  rownames(x_md) <- barcodes
  
  # Rename metadata column names
  new_colnames <- fcase(
    colnames(x[[]]) == "predicted.celltype.l2", "predicted.celltype.l2_pre-qc", 
    colnames(x[[]]) == "predicted.celltype.l2.score", "predicted.celltype.l2.score_pre-qc",
    rep_len(TRUE, ncol(x[[]])), colnames(x[[]])
  )
  
  names(x@meta.data) <- new_colnames
  
  # Add individual and pool information to Seurat object
  x <- AddMetaData(x, metadata = x_md)
  
  x
}

filtered_pools <- lapply(pools, filter_pool)
# Pool pool_40 skipped
# Pool pool_66 skipped

# Remove pool 40 and 66
i <- sapply(filtered_pools, inherits, "Seurat")
filtered_pools <- filtered_pools[i]
 
#   ____________________________________________________________________________
#   Export data                                                             ####

void <- mapply(function(obj, pool){
  message("Saving object ", pool)
  saveRDS(obj, file = here(output, pool %p% ".RDS"))
}, filtered_pools, names(filtered_pools))

#   ____________________________________________________________________________
#   Session info                                                            ####

print_session(here(output))
