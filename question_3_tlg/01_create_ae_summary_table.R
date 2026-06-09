###############################################################################
# Project    : Genentech Programming Assessment
# Question   : Question 3 - TLG Adverse Events Summary Table
#
# Purpose: Create an FDA-style adverse events summary table for treatment-
#          emergent adverse events (TEAEs) using pharmaverseadam::adae and adsl.
#
# Input: - pharmaverseadam::adae
#        - pharmaverseadam::adsl
#
# Output: - output/ae_summary_table.html
#         - output/ae_summary_table.pdf
#
###############################################################################
#Version      Author      Date          Description
#1.0          Yi Yang     06/07/2026    Initial AE Summary Table
###############################################################################
# -----------------------Setup -----------------------------------------------

required_packages <- c(
  "sdtm.oak",
  "pharmaverseraw",
  "pharmaversesdtm",
  "admiral",
  "dplyr",
  "haven",
  "tidyr",
  "stringr",
  "readr",
  "ggplot2",
  "gt",
  "htmltools",
  "metacore",
  "metatools",
  "gtsummary",
  "gt",
  "cards",
  "tfrmt"
)

installed_packages <- rownames(installed.packages())

for (pkg in required_packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg, dependencies = TRUE)
  }
}

lapply(required_packages, library, character.only = TRUE)

# Determine program folder regardless of whether the script is run from the
# project root or from within the question_3_tlg folder.
base_dir <- if (basename(getwd()) == "question_3_tlg") "." else "question_3_tlg"

log_file <- file.path(base_dir, "question_3_table_log.txt")
log_con <- file(log_file, open = "wt")

# Redirect output and messages
sink(log_con, split = TRUE)
sink(log_con, type = "message")



cat("Setup complete.\n")
cat("Required packages installed and loaded successfully.\n")
cat("Run time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n")

# ---------------------Load Data -----------------------------------------------
adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

adae1 <- adae %>% filter(TRTEMFL == "Y")

## ---- Add Total treatment group--------------------------------

adsl_total <- adsl %>%
  mutate(ACTARM = "Total")
adae_total <- adae1 %>%
  mutate(ACTARM = "Total")

adsl_all <- bind_rows(adsl, adsl_total)
adae_all <- bind_rows(adae1, adae_total)

# Get All treatment arms
arm_levels <- sort(unique(as.character(adae1$ACTARM)))

if (!("Total" %in% arm_levels)) {
  arm_levels <- c(arm_levels, "Total")
}

adsl_all <- adsl_all %>%
  mutate(ACTARM = factor(ACTARM, levels = arm_levels))

adae_all <- adae_all %>%
  mutate(ACTARM = factor(ACTARM, levels = arm_levels))

## ---- Create AE summary table ------------------------------------------------
# - Rows: AETERM or AESOC
# - Columns: Treatment groups (ACTARM)
# - Cell values: Count (n) and percentage (%)
# - Include total column with all subjects
# - Sort by descending frequency

ae_table <- adae_all %>%
  tbl_hierarchical(
    variables = c(AESOC, AETERM),  
    by = ACTARM,                   
    id = USUBJID,                 
    denominator = adsl_all,    
    overall_row = TRUE,            
    label = list(
      ..ard_hierarchical_overall.. = "Treatment Emergency AEs",
      AESOC = "Primary System Organ Class",
      AETERM = "Reported Term for the Adverse Event"
    )
  ) %>%
  # Sort to descending order
  sort_hierarchical(sort = "descending")

# HTML Output
as_gt(ae_table) %>%
  tab_header(
    title = "Summary of Treatment-Emergent Adverse Events (TEAE)"
    ) %>%
  tab_source_note(
    source_note = "Note: TEAE = Treatment-Emergent Adverse Event."
  ) %>%gtsave("AE_summary_table.html")

# PDF Output
as_gt(ae_table) %>%
  tab_header(
    title = "Summary of Treatment-Emergent Adverse Events (TEAE)"
    ) %>%
  tab_source_note(
    source_note = "Note: TEAE = Treatment-Emergent Adverse Event."
  ) %>%
  gtsave("AE_summary_table.pdf")

cat("Question 3 - 1 complete\n")
cat("Session information:\n")
print(sessionInfo())
cat("Program completed successfully.\n")

# Close sinks
sink(type = "message")
sink()

close(log_con)