#   ____________________________________________________________________________
#   Script information                                                      ####

# title: Determine thresholds for QC metrics and filter barcodes
# author: Jose Alquicira Hernandez
# date: 2021-10-28
# description: Determines and plots thresholds for QC metrics across by pool

#   ____________________________________________________________________________
#   HPC details                                                             ####

# screen -S qc_thr
# qrsh -N qc_thr -l mem_requested=100G -pe smp 1 -q short.q
# conda activate r-4.1.1

#   ____________________________________________________________________________
#   Import libraries                                                        ####

# Primary
library("stringr")
library("here")
library("dsLib")
library("data.table")
library("purrr")
library("ggplot2")
library("ggrepel")
library("patchwork")
library("colorspace")

#   ____________________________________________________________________________
#   Set output                                                              ####

output <- set_output("2021-10-28", "qc_filter_barcodes")

#   ____________________________________________________________________________
#   Import data                                                             ####

md <- readRDS("results/2021-10-26_pre-qc_metadata_aggregation/metadata.RDS")
md[, pool_number := str_remove(pool, "pool_")]
md[, pool_number := factor(pool_number, sort(unique(as.integer(pool_number))))]

# 1,550,233 cells

#   ____________________________________________________________________________
#   Extract singlets                                                        ####

path <- file.path("../onek1k_joseah/data", "singlets", "barcodes_assigned_to_ppl.txt")
singlets <- fread(file = here(path))
singlets[, id := paste(str_remove(BARCODE, "-.*$"), str_remove(batch, "sample"), sep = "-")]

# Keep singlets only
md_s <- md[barcode %chin% singlets$id]

# Add individual information to metadata
singlets <- singlets[id %chin% md_s$barcode]
singlets <- singlets[,.(barcode = id, individual = PERSON),]

md_s <- merge(md_s, singlets, by = "barcode")

# 1,306,442 cells

#   ____________________________________________________________________________
#   Get thresholds for QC metrics                                           ####

# Aggregate data by pool
md_s_pool <- md_s[, .(data = list(.SD)), by = .(pool, pool_number)]

# Create function to get the cutoffs based on Z-scores
get_thrs <- function(x, metric, mad_lower = 3, mad_upper = 2){
  
  ## Retrieve metric if interest across all pools 
  value <- x[[metric]]
  
  ## Get cutoffs depending on SDs

    x_median <- median(value)
    x_mad <- mad(value)
    higher <- x_median + mad_upper*x_mad
    lower <- x_median - mad_lower*x_mad
  
  
  # Return lower and upper thresholds
  list(lower = lower, higher = higher)
}


# Get thresholds
md_s_pool[, nCount_RNA_thr := lapply(data, get_thrs, metric = "nCount_RNA", mad_lower = 2, mad_upper = Inf)]
md_s_pool[, nFeature_RNA_thr := lapply(data, get_thrs, metric = "nFeature_RNA", mad_lower = 2, mad_upper = Inf)]
md_s_pool[, percent.mt_thr := lapply(data, get_thrs, metric = "percent.mt", mad_lower = Inf, mad_upper = 3)]

# Tidy threshold info for plotting
nCount_RNA_thr <- md_s_pool[ ,.(nCount_RNA = map_dbl(nCount_RNA_thr, "lower"), pool_number)]
nFeature_RNA_thr <- md_s_pool[ ,.(nFeature_RNA = map_dbl(nFeature_RNA_thr, "lower"), pool_number)]
percent.mt_thr <- md_s_pool[ ,.(percent.mt = map_dbl(percent.mt_thr, "higher"), pool_number)]

#   ____________________________________________________________________________
#   Plot distributions + thresholds                                         ####

p1 <- ggplot(md_s, aes(pool_number, nCount_RNA)) +
  geom_boxplot(outlier.size = 0.15, lwd = 0.35) +
  geom_line(aes(group = 1), data = nCount_RNA_thr, color = "red") +
  xlab("") +
  ylab("Number of UMIs") +
  theme_classic() +
  rotate_x()

p2 <- ggplot(md_s, aes(pool_number, nFeature_RNA)) +
  geom_boxplot(outlier.size = 0.15, lwd = 0.35) +
  geom_line(aes(group = 1), data = nFeature_RNA_thr, color = "red") +
  xlab("") +
  ylab("Number of genes") +
  theme_classic() +
  rotate_x()

p3 <- ggplot(md_s, aes(pool_number, percent.mt)) +
  geom_boxplot(outlier.size = 0.15, lwd = 0.35) +
  geom_line(aes(group = 1), data = percent.mt_thr, color = "red") +
  xlab("Pool") +
  ylab("% mitochondrial expression") +
  theme_classic() +
  rotate_x()

p <- p1 / p2 / p3

ggsave(here(output, "qc_metrics.png"), width = 8, height = 9, dpi = "print")
ggsave(here(output, "qc_metrics.pdf"), width = 8, height = 9, dpi = "print")

#   ____________________________________________________________________________
#   Filter data                                                             ####

# Get logical vectors per metric
md_s_pool[, nCount_RNA_pass := mapply(function(x, thr){
  x$nCount_RNA %between% thr
}, data, nCount_RNA_thr, SIMPLIFY = FALSE)]

md_s_pool[, nFeature_RNA_pass := mapply(function(x, thr){
  x$nFeature_RNA %between% thr
}, data, nFeature_RNA_thr, SIMPLIFY = FALSE)]

md_s_pool[, percent.mt_pass := mapply(function(x, thr){
  x$percent.mt %between% thr
}, data, percent.mt_thr, SIMPLIFY = FALSE)]

# Get consensus
md_s_pool[, index := mapply(function(x, y, z){
  x & y & z
}, nCount_RNA_pass, nFeature_RNA_pass, percent.mt_pass, SIMPLIFY = FALSE)]

# Filter data based on consensus
md_s_pool[, data_filter := mapply(function(x, i) x[i, ], data, index, SIMPLIFY = FALSE)]

# Get barcodes after QC
barcodes <- unlist(sapply(md_s_pool$data_filter, function(x) x$barcode))

# Subset metadata
md_qc <- md_s[barcode %chin% barcodes]

# Compare cell type proportions before and after QC
summary <- list(pre = md_s[, .(perc_pre = .N / nrow(md) * 100), predicted.celltype.l2], post = md_qc[, .(perc_post = .N / nrow(md) * 100), predicted.celltype.l2])
all_summ <- reduce(summary, merge, by = "predicted.celltype.l2")
all_summ[, ratio := perc_pre / perc_post]

p_ratio <- ggplot(all_summ, aes(perc_pre, perc_post, color = ratio)) +
  geom_point() +
  xlab(expression("log"[10]*"(% of cells "*italic(before)*" QC)")) +
  ylab(expression("log"[10]*"(% of cells "*italic(after)*" QC)")) +
  scale_x_log10() +
  scale_y_log10() +
  geom_abline(slope = 1, intercept = 0)  +
  geom_text_repel(aes(label = predicted.celltype.l2), size = 2) +
  scale_color_continuous_diverging(palette = "Berlin", name = "Ratio\n(pre/post QC)") +
  theme_classic()

ggsave(here(output, "cell_proportions.png"), width = 6, height = 4, dpi = "print")

# Save data ---------------------------------------------------------------

saveRDS(md_qc, file = here(output, "QC.RDS"))

# 1,249,037 cells

# Session info ------------------------------------------------------------
print_session(here(output))
