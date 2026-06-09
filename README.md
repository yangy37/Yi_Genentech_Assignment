# Genentech ADS Programming Assessment

This repository contains my submission for the **Genentech ADS Programming Assessment**, demonstrating experience in:

* CDISC SDTM dataset development
* CDISC ADaM dataset development
* TLG generation and visualization
* Generative AI applications for clinical data analysis

---

# Repository Structure

```text
Yi_Genentech_Assignment
│
├── question_1_sdtm/
├── question_2_adam/
├── question_3_tlg/
│   ├── question3_01_sumtable/
│   └── question3_02_visuals/
│
└── question_4_AI/
```

---

# Question 1 — SDTM DS Domain Creation

## Objective

Create an SDTM-compliant DS (Disposition) domain using the `{sdtm.oak}` framework.

## Key Deliverables

* SDTM DS derivation program
* Study-specific controlled terminology mapping
* Final DS dataset
* Execution log demonstrating successful run

## Output

* `ds_SDTM.csv`
* `ds_SDTM.xpt`
---

# Question 2 — ADaM ADSL Dataset Creation

## Objective

Create an ADaM ADSL (Subject-Level Analysis Dataset) using the `{admiral}` package and SDTM input domains.

## Key Deliverables

* ADSL derivation program
* Final ADSL dataset
* Execution log demonstrating successful run

## Output

* `adam_adsl.csv`
* `adam_adsl.xpt`
---

# Question 3 — TLG: Adverse Events Reporting

Generation of FDA-style adverse event tables and visualizations.

---

## 3.1 AE Summary Table

### Objective

Generate a treatment-emergent adverse event (TEAE) summary table suitable for clinical reporting.

### Output

* `AE_summary_table.html`
* `AE_summary_table.pdf`

### Features

* Subjects with ≥1 TEAE
* Severity breakdown
* Serious adverse events
* Discontinuations due to adverse events
* Deaths due to adverse events

---

## 3.2 AE Visualizations

### Objective

Create graphical summaries of adverse event data using `{ggplot2}`.

### Output

* `question_3_2_barchart.png`
* `question_3_2_forestplot.png`
* `qquestion_3_2_heatmap.png`

---

# Question 4 — Generative AI Clinical Data Assistant

## Objective

Develop a proof-of-concept clinical data assistant that enables users to query adverse event data using natural language.

## Workflow

```text
User Question
      ↓
Large Language Model
      ↓
Structured JSON Output
      ↓
Clinical Dataset Query
      ↓
Results Summary
```

## Components

### Prompt Engineering

Defines the AE schema and instructions for converting natural-language questions into structured query requests.

### Structured Output Parsing

Validates and standardizes LLM-generated JSON outputs.

### Query Execution Engine

Applies structured query logic to the clinical adverse event dataset using pandas.

### Clinical Data Agent

Combines prompt generation, parsing, and dataset filtering into a single workflow.

## Example Query

> Which subjects experienced severe headache adverse events?

## Example Structured Output

```json
{
  "target_column": "AETERM",
  "filter_value": "HEADACHE"
}
```

## Output

* Matching subject IDs
* Query summary
* Structured JSON interpretation

---

# Technologies Used

## Clinical Standards

* CDISC SDTM
* CDISC ADaM

## R

* sdtm.oak
* admiral
* dplyr
* gt
* ggplot2

## Python

* pandas
* LangChain
* OpenAI API

---

# Reproducibility

Each question folder contains:

* Source code
* Generated outputs
* Execution logs

The included run logs demonstrate successful execution and support reproducibility of all deliverables.

---

# Author

Yi Yang

MS in Biostatistics, New York University

Statistical Analyst / Statistical Programmer
