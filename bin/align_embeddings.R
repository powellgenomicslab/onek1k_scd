#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Align data
# author: Jose Alquicira Hernandez
# date: 2021-10-30
# description: Align data (all pools) using harmony


#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S align
# qrsh -N align -l mem_requested=300G -q long.q 
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

library("dsLib")
library("data.table")
library("Seurat")
library("SeuratDisk")
library("harmony")
library("ggplot2")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- set_output("2021-10-30", "aligned_data")

#   ____________________________________________________________________________
#   Import data                                                             ####

path <- "results/2021-10-30_combine_pools"
data <- LoadH5Seurat(here(path, "onek1k.h5Seurat"), 
                          assays =  list(RNA = "counts"))

#   ____________________________________________________________________________
#   Process data                                                            ####

data <- NormalizeData(data)
data <- FindVariableFeatures(data, nfeatures = 5000)
data <- ScaleData(data)

#   ____________________________________________________________________________
#   PCA                                                                     ####

data <- RunPCA(data)

#   ____________________________________________________________________________
#   Align data                                                              ####

inicio("Align embeddings")
alignment <- HarmonyMatrix(Embeddings(data, reduction = "pca"), meta_data = data[[]], 
                           vars_use = "pool", do_pca = FALSE,  
                           max.iter.harmony = 30,
                           epsilon.cluster = -Inf,
                           epsilon.harmony = -Inf)
fin()

data[["harmony"]] <- CreateDimReducObject(alignment, key = "harmony_", assay = "RNA")

data <- RunUMAP(data, dims = 1:40, reduction = "harmony")

#   ____________________________________________________________________________
#   Plot data                                                               ####


p <- DimPlot(data, group.by = "predicted.celltype.l2", reduction = "umap", 
             label = TRUE, repel = TRUE, label.size = 3)
p2 <- DimPlot(data, group.by = "pool_number", reduction = "umap") + NoLegend()


p <- p + xlab("UMAP 1") + ylab("UMAP 2") + ggtitle("") + theme(legend.text = element_text(size = 7))
p2 <- p2 + xlab("UMAP 1") + ylab("UMAP 2") + ggtitle("")


ggsave(here(output, "umap_integrated.png"), p, width = 8.3, height = 5.5, dpi = "print")
ggsave(here(output, "umap_integrated_pool.png"), p2, width = 6.3, height = 5.5, dpi = "print")

#   ____________________________________________________________________________
#   Export data                                                             ####

SaveH5Seurat(data, filename = here(output, "integrated.h5seurat"))
saveRDS(data, file = here(output, "integrated.RDS"))

#   ____________________________________________________________________________
#   Session info                                                            ####

print_session(here(output))
