# ==============================================================================
# Script Name: NCA_Analysis_Final.R
# Project: Perceived Naturalness and Consumer Cognitive Engagement
# Purpose: Perform NCA for PCE and TI, exporting 1200 DPI TIFF plots (A-H)
#          and formatted bottleneck tables.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Environment Setup & Global Configuration
# ------------------------------------------------------------------------------
if (!require("NCA")) install.packages("NCA")
library(NCA)

# Paths configuration
input_file  <- "DATA/latent_variable_scores.csv" 
output_dir  <- "NCA_Results"

# Create output directory if it doesn't exist
if (!dir.exists(output_dir)) dir.create(output_dir)

# Load Data
if (!file.exists(input_file)) stop("Error: Data file not found in DATA folder.")
data <- read.csv(input_file)

# ------------------------------------------------------------------------------
# 2. Analysis Task Definitions (Panels A-H)
# ------------------------------------------------------------------------------
analysis_tasks <- list(
  list(id = "A", x = "PN",     y = "TI",  label_x = "Perceived Naturalness"),
  list(id = "B", x = "PC",     y = "TI",  label_x = "Perceived Credibility"),
  list(id = "C", x = "Age",    y = "TI",  label_x = "Age"),
  list(id = "D", x = "PN",     y = "PCE", label_x = "Perceived Naturalness"),
  list(id = "E", x = "PC",     y = "PCE", label_x = "Perceived Credibility"),
  list(id = "F", x = "TI",     y = "PCE", label_x = "Taste Inference"),
  list(id = "G", x = "Age",    y = "PCE", label_x = "Age"),
  list(id = "H", x = "AgexTI", y = "PCE", label_x = "Age * Taste Inference")
)

y_label_mapping <- list(
  "TI"  = "Taste Inference", 
  "PCE" = "Product-related Cognitive Engagement"
)

# List to cache results for the summary report
all_results <- list()

# ------------------------------------------------------------------------------
# 3. Core NCA Analysis & Plotting (1200 DPI TIFF)
# ------------------------------------------------------------------------------
for (task in analysis_tasks) {
  t_id  <- task$id
  x_var <- task$x
  y_var <- task$y
  x_lab <- task$label_x
  y_lab <- y_label_mapping[[y_var]]
  
  message(sprintf(">>> Processing Panel %s: %s -> %s", t_id, x_var, y_var))
  
  # Run NCA Analysis (10,000 Permutations)
  model <- nca_analysis(data, x_var, y_var, 
                        ceilings = c("ols", "ce_fdh", "cr_fdh"), 
                        test.rep = 10000)
  
  # Cache result
  all_results[[t_id]] <- list(model = model, x = x_var, y = y_var, x_lab = x_lab, y_lab = y_lab)
  
  # Export High-Resolution Plot
  img_path <- file.path(output_dir, paste0("Fig5_", t_id, "_", x_var, "_vs_", y_var, ".tiff"))
  tiff(img_path, width = 6, height = 6, units = "in", res = 1200, compression = "lzw")
  par(mar = c(5, 5, 4, 2) + 0.1)
  plot(model, x_var, y_var, 
       add.on = "ols", 
       font.lab = 2, 
       xlab = x_lab, 
       ylab = y_lab, 
       main = paste0("Panel ", t_id))
  dev.off()
}

# ------------------------------------------------------------------------------
# 4. Export Combined Bottleneck Tables (Wide Format)
# ------------------------------------------------------------------------------
export_combined_bn <- function(dv_name, iv_names, file_name) {
  combined_list <- list()
  
  for (m in c("ce_fdh", "cr_fdh")) {
    group_df <- NULL
    for (x in iv_names) {
      # Extract bottleneck values for specific method
      res <- nca_analysis(data, x, dv_name, ceilings = m)
      bn <- as.data.frame(res$bottlenecks[[m]])
      
      if (is.null(group_df)) {
        group_df <- bn
        colnames(group_df)[2] <- paste0(x, "(", m, ")")
      } else {
        new_col <- bn[, 2, drop = FALSE]
        colnames(new_col) <- paste0(x, "(", m, ")")
        group_df <- cbind(group_df, new_col)
      }
    }
    combined_list[[m]] <- group_df
  }
  
  # Merge CE-FDH and CR-FDH columns
  final_tab <- merge(combined_list[["ce_fdh"]], combined_list[["cr_fdh"]], 
                     by = colnames(combined_list[["ce_fdh"]])[1], sort = FALSE)
  write.csv(final_tab, file.path(output_dir, file_name), row.names = FALSE)
}

# Execute Export
message(">>> Generating Combined Bottleneck Tables...")
export_combined_bn("TI",  c("PN", "PC", "Age"), "Combined_Bottleneck_TI.csv")
export_combined_bn("PCE", c("PN", "PC", "TI", "Age", "AgexTI"), "Combined_Bottleneck_PCE.csv")

# ------------------------------------------------------------------------------
# 5. Export Comprehensive Summary Report
# ------------------------------------------------------------------------------
summary_file <- file.path(output_dir, "NCA_Comprehensive_Summary.txt")
sink(summary_file)

cat("======================================================================\n")
cat("            NCA ANALYSIS STATISTICAL SUMMARY (PANELS A-H)             \n")
cat("            Generated Date:", as.character(Sys.time()), "             \n")
cat("======================================================================\n\n")

for (id in names(all_results)) {
  item <- all_results[[id]]
  cat("----------------------------------------------------------------------\n")
  cat(sprintf("### PANEL %s SUMMARY ###\n", id))
  cat(sprintf("Independent Variable (X): %s (%s)\n", item$x, item$x_lab))
  cat(sprintf("Dependent Variable   (Y): %s (%s)\n", item$y, item$y_lab))
  cat("----------------------------------------------------------------------\n")
  nca_output(item$model, summaries = TRUE)
  cat("\n\n")
}
sink()

# ------------------------------------------------------------------------------
# Completion Message
# ------------------------------------------------------------------------------
message("---")
message("Success! All NCA analysis tasks completed:")
message("1. Figures: 1200 DPI TIFF images (Panel A-H) generated.")
message("2. Tables: Combined_Bottleneck_TI.csv and Combined_Bottleneck_PCE.csv created.")
message("3. Report: NCA_Comprehensive_Summary.txt compiled with variable mappings.")
message("Results saved in: ", normalizePath(output_dir))
