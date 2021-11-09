#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Add sample-level metadata
# author: Jose Alquicira Hernandez
# date: 2021-11-10
# description: Add sample-level metadata (sex, age, ancestry pirlier)

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S add_meta
# qrsh -N add_meta -l mem_requested=200G -pe smp 1 -q short.q
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("Seurat")
library("SeuratDisk")
library("data.table")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- here("results", "2021-11-10_add_metadata")
dir.create(output)

#   ____________________________________________________________________________
#   Import data                                                             ####

data <- readRDS("results/2021-10-30_aligned_data/integrated.RDS")
sample_md <- fread("data/age_sex_info.tsv")
fam <- fread("../onek1k_genotypes/10-final/10-final.fam")
fam[, individual := paste(V1, V2, sep = "_")]
setnames(sample_md, "sampleid", "individual")

#   ____________________________________________________________________________
#   Add sex and age sample-level metadata                                   ####

md <- as.data.table(data[[]], keep.rownames = "barcode")
md <- merge(md, sample_md, by = "individual")
md <- md[, .(barcode, sex, age)]
md <- as.data.frame(md)

rownames(md) <- md$barcode
md$barcode <- NULL

data <- AddMetaData(data, md)

i <- fifelse(data$individual %chin% fam$individual, FALSE, TRUE)
data$ethnic_outlier <- i

#   ____________________________________________________________________________
#   Export data                                                             ####

SaveH5Seurat(data, filename = here(output, "onek1k.h5seurat"), overwrite = TRUE)
saveRDS(data, file = here(output, "onek1k.integrated.RDS"))

#   ____________________________________________________________________________
#   Session info                                                            ####

print_session(here(output))