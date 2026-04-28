# ==============================================================================
# Script Name: NCA_Analysis.R
# Project: Perceived Naturalness and Consumer Cognitive Engagement
# Purpose: Perform NCA for PCE and TI, exporting 1200 DPI TIFF plots (A-H)
#          and formatted bottleneck tables with 2-decimal precision.
# ==============================================================================

# ==============================================================================
# 1. Environment Setup
# ==============================================================================
if (!require("dplyr")) install.packages("dplyr")
if (!require("NCA")) install.packages("NCA")

library(NCA)
library(dplyr)

set.seed(123)

input_file <- "DATA/latent_variable_scores.csv"
output_dir <- "OUTPUT"

if (!dir.exists(output_dir)) dir.create(output_dir)

if (!file.exists(input_file)) {
  stop("Input file not found! Please ensure 'latent_variable_scores.csv' is in the DATA/ folder.")
}
my_data <- read.csv(input_file)

# Configuration strictly following the Layout of Figure 5 (Panels A-H)
analysis_tasks <- list(
  list(id = "A", x = "PN",     y = "TI",  label = "Perceived Naturalness"),
  list(id = "B", x = "PC",     y = "TI",  label = "Perceived Credibility"),
  list(id = "C", x = "Age",    y = "TI",  label = "Age"),
  list(id = "D", x = "PN",     y = "PCE", label = "Perceived Naturalness"),
  list(id = "E", x = "PC",     y = "PCE", label = "Perceived Credibility"),
  list(id = "F", x = "TI",     y = "PCE", label = "Taste Inference"),
  list(id = "G", x = "Age",    y = "PCE", label = "Age"),
  list(id = "H", x = "AgexTI", y = "PCE", label = expression(Age %*% Taste~Inference))
)

y_label_mapping <- list(
  "TI"  = "Taste Inference", 
  "PCE" = "Product-related Cognitive Engagement"
)

# ==============================================================================
# 2. Execution & Export
# ==============================================================================
original_wd <- getwd()

for (task in analysis_tasks) {
  message(sprintf("Processing Panel %s: %s -> %s", task$id, task$x, task$y))
  
  # 1. Perform NCA Analysis
  # Includes 10,000 permutations for significance testing
  model <- nca_analysis(my_data, task$x, task$y, 
                        ceilings = c('ols', 'ce_fdh', 'cr_fdh'), 
                        test.rep = 10000)
  
  # 2. Export TIFF Plot (1200 DPI)
  plot_file <- file.path(original_wd, output_dir, paste0("Fig5", task$id, "_", task$x, "_", task$y, ".tiff"))
  
  tiff(
    filename = plot_file,
    width = 6, height = 6, units = "in", 
    res = 1200, compression = "lzw"
  )
  
  plot(
    model,
    xlab = task$label,
    ylab = y_label_mapping[[task$y]],
    main = paste0("Scatter Plot 5", task$id),
    font.lab = 2,
    add.on = "ols"
  )
  
  dev.off()
  # ==============================================================================
  # 3. Export Bottleneck Tables (Rounded to 2 decimals)
  # ==============================================================================
  # Switch to OUTPUT to use nca_output for summaries
  setwd(file.path(original_wd, output_dir))
  
  # Export the general summary text file for this task
  sink(paste0("Summary_Fig5", task$id, ".txt"))
  nca_output(model, summaries = TRUE)
  sink()
  
  # Process and save rounded Bottleneck CSVs
  bn_list <- model$bottlenecks
  for(line_name in names(bn_list)) {
    bn_rounded <- as.data.frame(bn_list[[line_name]])
    bn_rounded[,-1] <- round(bn_rounded[,-1], 2)
    write.csv(bn_rounded, 
              paste0("Bottleneck_Fig5", task$id, "_", line_name, ".csv"), 
              row.names = FALSE)
  }
  
  # Reset path for next iteration
  setwd(original_wd)
}

message("================================================================")
message("Analysis Complete!")
message("TIFF plots (1200 DPI) and formatted tables saved in: ", output_dir)
message("================================================================")
