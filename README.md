# NCA_Analysis for Study

This repository contains the data and R code required to reproduce the **Necessary Condition Analysis (NCA)** results presented in the manuscript.

##  Repository Structure

* **NCA_Analysis_Final.R**: The main script for data processing, statistical testing, and high-resolution figure generation.
* **DATA/**: Directory containing `latent_variable_scores.csv` (input data).
* **OUTPUTS/**: Directory where outputs (plots, bottleneck tables, and summaries) are saved.
* **NCA_Analysis.Rproj**: RProject file to handle working directories automatically.

##  Reproduction Steps

1.  **Software**: Ensure you have **R (>= 4.0.0)** installed.
2.  **Dependencies**: The script automatically checks for and installs the `NCA` package if missing. 
3.  **Execution**: 
    * Open the **`.Rproj`** file in RStudio (this ensures the working directory is correctly mapped to the project root).
    * Open and run `NCA_Analysis_Final.R`.
4.  **Performance Note (IMPORTANT)**: 
    * The script uses `test.rep = 10000` to ensure statistical stringency (stable p-values) and `res = 1200` for publication-quality TIFFs.
    * **Execution is computationally intensive.** Depending on your CPU, it may take **5 to 15 minutes** to complete all 8 panels (A-H). 
    * Please do not close RStudio until the message *"All NCA analysis tasks completed successfully!"* appears in the console.

##  Outputs

Upon successful execution, the following files will be generated in the `OUTPUTS/` folder:

* **TIFF Plots**: Eight high-resolution (**1200 DPI**) plots (`Fig5_A` through `Fig5_H`) with OLS regression lines.
* **Bottleneck Tables**: 
    * `Combined_Bottleneck_TI.csv`: Combined results for the outcome "Taste Inference."
    * `Combined_Bottleneck_PCE.csv`: Combined results for the outcome "Product-related Cognitive Engagement."
* **Statistical Summary**: `NCA_Comprehensive_Summary.txt` containing effect sizes ($d$), $p$-values, and variable mappings for all panels.

##  Technical Requirements

The input `latent_variable_scores.csv` must include the following variables as defined in the script:

* **Predictors/Moderators**: `PN` (Perceived Naturalness), `PC` (Perceived Credibility), `Age`, `AgexTI` (Interaction).
* **Outcomes**: `TI` (Taste Inference), `PCE` (Product-related Cognitive Engagement).

##  License

This project is licensed under the **MIT License**.

##  Contact

For questions regarding the analysis or data, please contact the corresponding author at: **sunlili77@foxmail.com**.
