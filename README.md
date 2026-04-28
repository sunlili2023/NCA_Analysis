# NCA_Analysis for Perceived Naturalness Study

This repository contains the data and R code required to reproduce the Necessary Condition Analysis (NCA) results presented in the manuscript.

##  Repository Structure
* **NCA_Analysis.R**: The main script for data processing, statistical testing, and figure generation.
* **DATA/**: Directory containing `latent_variable_scores.csv`.

##  Reproduction Steps
1.  **Software**: Ensure you have R (>= 4.0.0) installed.
2.  **Dependencies**: The script will automatically install `dplyr` and `NCA` packages if they are missing.
3.  **Execution**: Run the `NCA_Analysis.R` script. 
4.  **Outputs**: 
    * The script calculates sum scores for latent variables based on the column prefixes (PN, PC, TI, PCE, Age).
    * It performs 10,000 permutations for p-value calculation.
    * High-resolution TIFF plots (1200 DPI) and summary text files will be generated in a new `/OUTPUT` folder.

##  Technical Requirements
The input CSV must follow the naming convention used in the script (refer to the **Measures** section in the manuscript for variable mapping):
* Prefixes: `PN`, `PC`, `TI`, `PCE`, `Age`.

##  License
This project is licensed under the MIT License.

##  Contact
For questions regarding the analysis or data, please contact the author at: sunlili77@foxmail.com.
