#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Aggregate metadata
# author: Jose Alquicira Hernandez
# date: 2021-10-26
# description: Aggregates metadata across all pools

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S aggregate_md
# qrsh -N aggregate_md -l mem_requested=50G -pe smp 1 -q short.q
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("data.table")
library("Seurat")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- set_output("2021-10-26", "pre-qc_metadata_aggregation")

#   ____________________________________________________________________________
#   Import data                                                             ####

input <- "results/2021-10-26_pre-qc_annotation"

pool_names <- list.dirs(input)[-1]

md <- lapply(pool_names, function(x){
  message("Reading ", x)
  x <- readRDS(here(x, "query.RDS"))
  as.data.table(x[[]], keep.rownames = "barcode")
})

all_md <- rbindlist(md)

#   ____________________________________________________________________________
#   Export data                                                             ####

saveRDS(all_md, here(output, "metadata.RDS"))

#   ____________________________________________________________________________
#   Session info                                                            ####

print_session(here(output))