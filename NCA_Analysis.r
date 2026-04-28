# ==============================================================================
# Script Name: NCA_Analysis.R
# Project: Perceived Naturalness and Consumer Cognitive Engagement
# Purpose: Perform Necessary Condition Analysis (NCA) for PCE and TI, 
#          exporting results to a dedicated OUTPUT folder with 2-decimal precision.
# ==============================================================================


# ==============================================================================
# 1. Environment Setup
# ==============================================================================
# Install missing packages if necessary
if (!require("dplyr")) install.packages("dplyr")
if (!require("NCA")) install.packages("NCA")

library(NCA)
library(dplyr)

# Set seed to ensure reproducibility of the Permutation Test results (p-values)
set.seed(123)

input_file <- "DATA/latent_variable_scores.csv"
output_dir <- "OUTPUT"

# Create output directory if it does not exist
if (!dir.exists(output_dir)) dir.create(output_dir)

# Load Dataset
if (!file.exists(input_file)) {
  stop("Input file not found! Please ensure 'latent_variable_scores.csv' is in the DATA/ folder.")
}
my_data <- read.csv(input_file)

# Store the root directory to reset paths later
original_wd <- getwd()

# ==============================================================================
# 2. Analysis Group 1: Dependent Variable = PCE
# ==============================================================================
message("Running NCA for PCE (10,000 permutations)...")

x_pce <- c("PN", "PC", "TI", "Age", "AgexTI")
model_pce <- nca_analysis(my_data, x_pce, "PCE", 
                          ceilings = c('ols', 'ce_fdh', 'cr_fdh'), 
                          test.rep = 10000)

# Switch to OUTPUT directory to export PDF and TXT files
setwd(output_dir)
nca_output(model_pce, plots = TRUE, summaries = TRUE, pdf = TRUE)

# Process Bottleneck Tables: Round to 2 decimal places and export as CSV
bn_pce <- model_pce$bottlenecks
for(name in names(bn_pce)) {
  bn_rounded <- as.data.frame(bn_pce[[name]])
  # Round all columns except the first one (percentage column)
  bn_rounded[,-1] <- round(bn_rounded[,-1], 2)
  write.csv(bn_rounded, paste0("Bottleneck_PCE_", name, ".csv"), row.names = FALSE)
}

# Reset to root directory
setwd(original_wd)

# ==============================================================================
# 3. Analysis Group 2: Dependent Variable = TI
# ==============================================================================
message("Running NCA for TI (10,000 permutations)...")

x_ti <- c("PN", "PC", "Age")
model_ti <- nca_analysis(my_data, x_ti, "TI", 
                         ceilings = c('ols', 'ce_fdh', 'cr_fdh'),
                         test.rep = 10000)

setwd(output_dir)
nca_output(model_ti, plots = TRUE, summaries = TRUE, pdf = TRUE)

# Process Bottleneck Tables for TI
bn_ti <- model_ti$bottlenecks
for(name in names(bn_ti)) {
  bn_rounded <- as.data.frame(bn_ti[[name]])
  bn_rounded[,-1] <- round(bn_rounded[,-1], 2)
  write.csv(bn_rounded, paste0("Bottleneck_TI_", name, ".csv"), row.names = FALSE)
}

# Final reset to root directory
setwd(original_wd)

message("================================================================")
message("Analysis Complete!")
message("PDF plots and formatted Bottleneck tables saved in: ", output_dir)
message("================================================================")
