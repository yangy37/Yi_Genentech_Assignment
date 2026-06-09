###############################################################################
# Project    : Genentech Programming Assessment
# Question   : Question 2 - ADaM ADSL Domain Creation
#
# Purpose: Create ADaM DS domain using pharmaverseraw::dm, vs, ex, ds, ae
#
# Input: - pharmaversesdtm::dm, pharmaversesdtm::vs, pharmaversesdtm::ex,
#          pharmaversesdtm::ds, pharmaversesdtm::ae
#
# Output:  - output/ADSL.xpt, output/ADSL.csv
#
###############################################################################
#Version      Author      Date          Description
#1.0          Yi Yang     06/06/2026    Initial ADSL Program
###############################################################################
# ------------Setup ---------------------------------------
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
  "metatools"
)

installed_packages <- rownames(installed.packages())

for (pkg in required_packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg, dependencies = TRUE)
  }
}

invisible(lapply(required_packages, library, character.only = TRUE))

base_dir <- if (basename(getwd()) == "question_2_adam") "." else "question_2_adam"
log_file <- file.path(base_dir, "question_2_log.txt")
output_dir <- file.path(base_dir)


cat("Setup complete.\n")
cat("Required packages installed and loaded successfully.\n")
cat("Run time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n")


# log output ─────────────────────────────────────────────────────────────────── 
log_con <- file(log_file, open = "wt")

# Redirect output and messages
sink(log_con, split = TRUE)
sink(log_con, type = "message")

cat("Program started at:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n")

# ---------------------Load Data -----------------------------------------------
dm <- convert_blanks_to_na(pharmaversesdtm::dm)
vs <- convert_blanks_to_na(pharmaversesdtm::vs)
ex <- convert_blanks_to_na(pharmaversesdtm::ex)
ds <- convert_blanks_to_na(pharmaversesdtm::ds)
ae <- convert_blanks_to_na(pharmaversesdtm::ae)

# Convert blanks in data to NA
dm <- convert_blanks_to_na(dm)
vs <- convert_blanks_to_na(vs)
ex <- convert_blanks_to_na(ex)
ds <- convert_blanks_to_na(ds)
ae <- convert_blanks_to_na(ae)

# No Spec provided
# metacore <- spec_to_metacore(
#   path = "safety_specs.xlsx",
#   # All datasets are described in the same sheet
#   where_sep_sheet = FALSE
# ) %>%
#   select_dataset("ADSL")

adsl <- dm %>%
  mutate(TRT01P = ARM, TRT01A = ACTARM)

# ------------Derive AGEGR9 / AGEGR9N ---------------------------------------
# Logic: AGEGR9: Categorical age group from DM.AGE: "<18", "18 - 50", ">50"
#        AGEGR9N: Numeric version of AGEGR9 with categories coded as 1, 2, 3
agegr9_lookup <- exprs(
  ~condition, ~AGEGR9, ~AGEGR9N,
  AGE < 18, "<18", 1,
  between(AGE, 18, 50), "18 - 50", 2,
  AGE > 50, ">50", 3
)

adsl <- adsl %>%
  derive_vars_cat(definition = agegr9_lookup)

# ------------ Derive TRTSDTM / TRTSTMF ---------------------------------------
# Logic: Derive TRTSDTM as the numeric datetime of the subject's first valid exposure
# start date/time from EX.EXSTDTC, after sorting exposure records in chronological
# order.
#
# Include only exposure records where:
#   1. The subject received a valid dose; and
#   2. The date portion of EX.EXSTDTC is complete.
#
# Time imputation:
#   - If time is completely missing, impute as 00:00:00.
#   - If hour, minute, or second is partially missing, impute the missing
#     component(s) as 00.
#   - If only seconds are missing, do not populate TRTSTMF.
#
# TRTSTMF indicates whether time imputation was applied, except when only
# seconds were missing.


# Derive date time object for treatment start date
ex_ext <- ex %>%
  derive_vars_dtm(
    dtc = EXSTDTC,
    new_vars_prefix = "EXST"
  ) %>%
  derive_vars_dtm(
    dtc = EXENDTC,
    new_vars_prefix = "EXEN",
    time_imputation = "last"
  )

adsl <- adsl%>%
  # Treatment Start Datetime TRTSDTM TRTSTMF
  derive_vars_merged(
    dataset_add = ex_ext,
    by_vars = exprs(STUDYID, USUBJID),
    filter_add = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) &
      !is.na(EXSTDTM),
    new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first"
  ) %>%
  # Treatment End Datetime TRTEDTM TRTETMF
  derive_vars_merged(
    dataset_add = ex_ext,
    by_vars = exprs(STUDYID, USUBJID),
    filter_add = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) &
      !is.na(EXENDTM),
    new_vars = exprs(TRTEDTM = EXENDTM, TRTETMF = EXENTMF),
    order = exprs(EXENDTM, EXSEQ),
    mode = "last"
  ) %>%
  # Treatment Start and End Date
  derive_vars_dtm_to_dt(source_vars = exprs(TRTSDTM, TRTEDTM)) %>% 
  derive_var_trtdurd() %>%
  # Safety Population Flag
  derive_var_merged_exist_flag(
    dataset_add = ex,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = SAFFL,
    false_value = "N",
    missing_value = "N",
    condition = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO")))
  ) %>% mutate(
    TRTSDTM = format(TRTSDTM, "%Y-%m-%dT%H:%M:%S"),
    TRTEDTM = format(TRTEDTM, "%Y-%m-%dT%H:%M:%S")
  )

# ------------Derive ITTFL ---------------------------------------------------
# Logic: Set to "Y" if [DM.ARM] not equal to missing Else set to "N"
adsl <- adsl %>%
  mutate(
    ITTFL = if_else(!is.na(ARM) & is.na(ARMNRS), "Y", "N")
  )

# ------------ Derive LSTAVLDT -----------------------------------------------
# Logic:
# Derive LSTAVLDT as the latest known alive date from the following sources:
#
#   - VS: Latest complete VSDTC with a non-missing result
#         (VSSTRESN or VSSTRESC populated)
#   - AE: Latest complete AESTDTC
#   - DS: Latest complete DSSTDTC
#   - Treatment: Date part of TRTEDTM (last valid exposure datetime)
#
# LSTAVLDT is set to the maximum date across all eligible sources.
# Partial or incomplete dates are excluded from the derivation.
# ---------------------------------------------------------------------------
adsl <- adsl %>%
  derive_vars_extreme_event(
    by_vars = exprs(STUDYID, USUBJID),
    events = list(
      # (1) last complete date of vital assessment with a valid test result 
      # ([VS.VSSTRESN] and [VS.VSSTRESC] not both missing) and datepart of [VS.VSDTC] not missing.
      event(
        dataset_name = "vs",
        order = exprs(VSDTC, VSSEQ),
        condition = !(is.na(VSSTRESN) & is.na(VSSTRESC)) &
          !is.na(convert_dtc_to_dt(VSDTC)),
        set_values_to = exprs(
          LSTAVLDT = convert_dtc_to_dt(VSDTC),
          seq = VSSEQ
        )
      ),
      # (2) last complete onset date of AEs (datepart of Start Date/Time of Adverse Event [AE.AESTDTC]).
      event(
        dataset_name = "ae",
        order = exprs(AESTDTC, AESEQ),
        condition = !is.na(convert_dtc_to_dt(AESTDTC)),
        set_values_to = exprs(
          LSTAVLDT = convert_dtc_to_dt(AESTDTC),
          seq = AESEQ
        )
      ),
      # (3) last complete disposition date (datepart of Start Date/Time of Disposition Event [DS.DSSTDTC]).
      event(
        dataset_name = "ds",
        order = exprs(DSSTDTC, DSSEQ),
        condition = !is.na(convert_dtc_to_dt(DSSTDTC)),
        set_values_to = exprs(
          LSTAVLDT = convert_dtc_to_dt(DSSTDTC),
          seq = DSSEQ
        )
      ),
      # (4) last date of treatment administration where patient received a valid
      # dose (datepart of Datetime of Last Exposure to Treatment [ADSL.TRTEDTM]).
      event(
        dataset_name = "adsl",
        condition = !is.na(TRTEDT),
        set_values_to = exprs(
          LSTAVLDT = TRTEDT,
          seq = 0
        )
      )
    ),
    source_datasets = list(vs = vs, ae = ae, ds = ds, adsl = adsl),
    tmp_event_nr_var = event_nr,
    order = exprs(LSTAVLDT, seq, event_nr),
    mode = "last",
    new_vars = exprs(LSTAVLDT)
  )

# ── Write output ───────────────────────────────────────────────────────────────
adsl <- adsl %>% select(-DOMAIN)

labels <- c(
  STUDYID  = "Study Identifier",
  DOMAIN   = "Domain Abbreviation",
  USUBJID  = "Unique Subject Identifier",
  SUBJID   = "Subject Identifier for the Study",
  
  RFSTDTC  = "Subject Reference Start Date/Time",
  RFENDTC  = "Subject Reference End Date/Time",
  RFXSTDTC = "Date/Time of First Study Treatment",
  RFXENDTC = "Date/Time of Last Study Treatment",
  RFICDTC  = "Date/Time of Informed Consent",
  RFPENDTC = "Date/Time of End of Participation",
  
  DTHDTC   = "Date/Time of Death",
  DTHFL    = "Subject Death Flag",
  
  SITEID   = "Study Site Identifier",
  BRTHDTC  = "Date/Time of Birth",
  
  AGE      = "Age",
  AGEU     = "Age Units",
  SEX      = "Sex",
  RACE     = "Race",
  ETHNIC   = "Ethnicity",
  
  ARMCD    = "Planned Arm Code",
  ARM      = "Description of Planned Arm",
  ACTARMCD = "Actual Arm Code",
  ACTARM   = "Description of Actual Arm",
  
  COUNTRY  = "Country",
  
  DMDTC    = "Date/Time of Collection",
  DMDY     = "Study Day of Collection",
  
  ARMNRS   = "Planned Arm Numeric Code",
  ACTARMUD = "Actual Arm Description",
  
  TRT01P   = "Planned Treatment for Period 01",
  TRT01A   = "Actual Treatment for Period 01",
  
  AGEGR9   = "Age Group (9-Year Intervals)",
  AGEGR9N  = "Age Group (9-Year Intervals) Numeric",
  
  TRTSDTM  = "Datetime of First Exposure to Treatment",
  TRTSTMF  = "Time of First Exposure Imputation Flag",
  
  TRTEDTM  = "Datetime of Last Exposure to Treatment",
  TRTETMF  = "Time of Last Exposure Imputation Flag",
  
  TRTSDT   = "Date of First Exposure to Treatment",
  TRTEDT   = "Date of Last Exposure to Treatment",
  
  TRTDURD  = "Total Treatment Duration (Days)",
  
  SAFFL    = "Safety Population Flag",
  ITTFL    = "Intent-to-Treat Population Flag",
  
  LSTAVLDT = "Date of Last Available Record"
)

# Dataset label
attr(adsl, "label") <- "Subject Level Analysis"

# Variable labels
for (v in intersect(names(labels), names(adsl))) {
  attr(adsl[[v]], "label") <- labels[[v]]
}
# CSV output
write.csv(adsl, file.path(output_dir, "adsl.csv"), row.names = FALSE, na = "")

# XPT output
haven::write_xpt(adsl, "adsl.xpt")

cat("Question 2 complete\n")
cat("Total Records:", nrow(adsl), "\n")
cat("All Variables:", paste(names(adsl), collapse = ", "), "\n\n")
cat("Session information:\n")
print(sessionInfo())

# Close sinks
sink(type = "message")
sink()

close(log_con)