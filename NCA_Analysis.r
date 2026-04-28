# ==============================================================================
# Script Name: NCA_Analysis.R
# Project: Perceived Naturalness and Consumer Cognitive Engagement
# Purpose: Reproduce all Necessary Condition Analysis (NCA) results and 
#          scatter plots for the manuscript (Figure 5, Panels A-H).
# ==============================================================================

# ================== 1. Environment Setup ==================
# Install missing packages if necessary
if (!require("dplyr")) install.packages("dplyr")
if (!require("NCA")) install.packages("NCA")

library(dplyr)
library(NCA)

# Set seed to ensure reproducibility of the Permutation Test results (p-values)
set.seed(123)

# ================== 2. Path Management ==================
# Expected Repository Structure:
# [Project Root]
#  ├── DATA/ (Place 'latent_variable_scores.csv' here)
#  └── NCA_Analysis.R

input_file  <- "DATA/latent_variable_scores.csv" 
output_dir  <- "OUTPUT/"

# Create output directory if it does not exist
if (!dir.exists(output_dir)) dir.create(output_dir)

# ================== 3. Data Loading & Pre-processing ==================
if (!file.exists(input_file)) {
  stop("Input file not found! Please ensure 'latent_variable_scores.csv' is in the DATA/ folder.")
}

# Load dataset
df_raw <- read.csv(input_file, fileEncoding = "UTF-8-BOM")

# Calculate Sum Scores for Latent Variables
# Aggregating indicators into composite variables based on study definitions
df <- df_raw %>%
  mutate(
    # Antecedent Variables
    PN  = rowSums(select(., starts_with("PN")),  na.rm = TRUE), # Perceived Naturalness
    PC  = rowSums(select(., starts_with("PC")),  na.rm = TRUE), # Perceived Credibility
    TI  = rowSums(select(., starts_with("TI")),  na.rm = TRUE), # Taste Inference
    # Outcome Variable
    PCE = rowSums(select(., starts_with("PCE")), na.rm = TRUE), # Cognitive Engagement
    # Moderator and Interaction Term
    Age = rowSums(select(., starts_with("Age")), na.rm = TRUE),
    AgexTI = rowSums(select(., starts_with("AgexTI")), na.rm = TRUE)
  )

# ================== 4. Task Configuration ==================
# Configuration strictly following the Layout of Figure 5 (Panels A-H)
analysis_tasks <- list(
  # Row 1: Necessary conditions for Taste Inference (TI)
  list(id = "A", x = "PN",     y = "TI",  label = "Perceived Naturalness"),
  list(id = "B", x = "PC",     y = "TI",  label = "Perceived Credibility"),
  list(id = "C", x = "Age",    y = "TI",  label = "Age"),
  
  # Row 2: Necessary conditions for Cognitive Engagement (PCE)
  list(id = "D", x = "PN",     y = "PCE", label = "Perceived Naturalness"),
  list(id = "E", x = "PC",     y = "PCE", label = "Perceived Credibility"),
  list(id = "F", x = "TI",     y = "PCE", label = "Taste Inference"),
  
  # Row 3: Individual differences and Interaction effects
  list(id = "G", x = "Age",    y = "PCE", label = "Age"),
  list(id = "H", x = "AgexTI", y = "PCE", label = expression(Age %*% Taste~Inference))
)

# ================== 5. Execution & Export ==================
y_label_mapping <- list(
  "TI"  = "Taste Inference", 
  "PCE" = "Product-related Cognitive Engagement"
)

for (task in analysis_tasks) {
  message(sprintf("Processing Figure 5%s: %s -> %s", task$id, task$x, task$y))
  
  # 1. Perform NCA Analysis
  # Including CE-FDH and CR-FDH ceilings with 10,000 permutations for significance testing
  nca_res <- nca_analysis(
    data = df,
    x = task$x,
    y = task$y,
    ceilings = c('CE_FDH', 'CR_FDH'),
    test.rep = 10000 
  )
  
  # 2. Export Statistical Summary (TXT)
  summary_file <- paste0(output_dir, "NCA_Summary_Fig5", task$id, ".txt")
  sink(summary_file)
  nca_output(nca_res, summaries = TRUE)
  sink()
  
  # 3. Export High-Resolution Scatter Plots (TIFF)
  # Standardized at 1200 DPI for high-quality journal publication
  plot_file <- paste0(output_dir, "Fig5", task$id, "_", task$x, "_", task$y, ".tiff")
  
  tiff(
    filename = plot_file,
    width = 6, height = 6, units = "in", 
    res = 1200, compression = "lzw"
  )
  
  # Plotting Configuration
  plot(
    nca_res,
    xlab = task$label,
    ylab = y_label_mapping[[task$y]],
    main = paste0("Scatter Plot 5", task$id),
    font.lab = 2
  )
  
  dev.off()
}

message("================================================================")
message("All NCA analysis tasks completed successfully!")
message("Results saved in: ", normalizePath(output_dir))
message("================================================================")