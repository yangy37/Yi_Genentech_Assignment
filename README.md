# Genentech ADS Programming Assessment

This repository contains my submission for the **Genentech ADS Programming Assessment**, demonstrating experience in:

* CDISC SDTM dataset development
* CDISC ADaM dataset development
* Clinical reporting through Tables, Listings, and Figures (TLGs)
* Generative AI applications for clinical data analysis

---

# Repository Structure

```text
Yi_Genentech_Assignment
│
├── question_1_sdtm/
│
├── question_2_adam/
│
├── question_3_tlg/
│
└── question_4_AI/
```

---

# Question 1 — SDTM DS Domain Creation

## Objective

Create an SDTM-compliant DS (Disposition) domain using the `{sdtm.oak}` package.

## Files

### `01_create_ds_domain.R`

Main derivation program that:

* Reads raw disposition data
* Maps study-specific controlled terminology
* Derives required SDTM DS variables
* Generates the final SDTM DS dataset

### `sdtm_ct.csv`

Study-specific controlled terminology used for disposition mapping.

### `question_1_sdtm_log.txt`

Execution log demonstrating successful program execution.

## Output

* `ds_SDTM.csv`
* `ds_SDTM.xpt`

---

# Question 2 — ADaM ADSL Dataset Creation

## Objective

Create an ADaM ADSL (Subject-Level Analysis Dataset) using the `{admiral}` package and SDTM input domains.

## Files

### `create_adsl.R`

Main derivation program that:

* Reads SDTM domains
* Derives subject-level analysis variables
* Creates analysis populations
* Produces an ADaM-compliant ADSL dataset

### `question_2_adam_log.txt`

Execution log demonstrating successful program execution.

## Output

* `adam_adsl.csv`
* `adam_adsl.xpt`

---

# Question 3 — TLG: Adverse Events Reporting

Generation of FDA-style adverse event tables and visualizations.

---

## 3.1 AE Summary Table

### Objective

Generate a Treatment-Emergent Adverse Event (TEAE) summary table suitable for clinical reporting.

### Program

#### `01_create_ae_summary_table.R`

Creates:

* Overall TEAE summary
* Serious adverse events
* AE-related discontinuations
* AE-related deaths
* Severity breakdown by treatment group

### Output

* `AE_summary_table.html`
* `AE_summary_table.pdf`

---

## 3.2 AE Visualizations

### Objective

Create graphical summaries of adverse event data.

### Program

#### `02_create_visualizations.R`

Generates:

* AE Severity Distribution by Treatment (Stacked Bar Chart)
* Top 10 Most Frequent TEAEs (Forest Plot with 95% Confidence Intervals)
* AE Heatmap Visualization

### Output

* `question_3_2_barchart.png`
* `question_3_2_forestplot.png`
* `question_3_2_heatmap.png`

---

# Question 4 — Generative AI Clinical Data Assistant

## Objective

Develop a proof-of-concept Clinical Data Assistant that enables users to query adverse event data using natural language.

## Workflow

```text
User Question
      ↓
Prompt Generation
      ↓
OpenAI LLM
      ↓
Structured JSON Output
      ↓
Clinical Dataset Query
      ↓
Results Summary
      ↓
PDF Report Generation
```

## Program Files

### `clinical_trial_data_agent.py`

Main application entry point.

Responsibilities:

* Executes the end-to-end AI workflow
* Processes example user questions
* Coordinates prompt generation, parsing, and query execution
* Displays structured JSON outputs and query results
* Generates a PDF report containing all query results

---

### `prompt.py`

Prompt engineering module.

Responsibilities:

* Defines the adverse event dataset schema
* Provides instructions for converting natural-language questions into structured queries
* Creates prompts sent to the LLM

---

### `parser.py`

Structured output parser.

Responsibilities:

* Validates LLM responses
* Converts responses into a standardized JSON structure
* Extracts query parameters used for dataset filtering

Example output:

```json
{
  "target_column": "AETERM",
  "filter_value": "HEADACHE"
}
```

---

### `agent.py`

Clinical data query engine.

Responsibilities:

* Applies structured query logic
* Filters the adverse event dataset
* Returns matching records and summary results

---

### `ae_dataset.csv`

Sample adverse event dataset used by the AI assistant.

---

## Running the AI Assistant

### Prerequisites

Install the required Python packages:

```bash
pip install -r requirements.txt
```

### Environment Setup

Create a `.env` file inside the `question_4_AI` directory and add your OpenAI API key:

```text
OPENAI_API_KEY=YOUR_API_KEY_HERE
```

Example:

```text
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> **Note:** The `.env` file is intentionally excluded from the repository and should never be committed to GitHub.

### Run the Application

Navigate to the AI assistant directory:

```bash
cd question_4_AI
```

Run the application:

```bash
python clinical_trial_data_agent.py
```

### Customizing Example Questions

To test additional clinical questions, open:

```text
clinical_trial_data_agent.py
```

Locate the example question list:

```python
questions = [
    "Which subjects experienced severe headache adverse events?"
]
```

Add additional questions to the list as needed.

Each question will be processed through the complete workflow:

```text
Natural Language Question
            ↓
Prompt Generation
            ↓
OpenAI LLM
            ↓
Structured JSON Output
            ↓
Dataset Query
            ↓
Results Summary
            ↓
PDF Report
```

---

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

For each example question, the application generates:

* Structured JSON interpretation
* Matching subject IDs
* Query results summary

Additionally, all query results are compiled into a PDF report:

```text
question4_results.pdf
```

The PDF report contains:

* Original user question
* LLM-generated structured JSON output
* Matching adverse event records
* Query result summaries
