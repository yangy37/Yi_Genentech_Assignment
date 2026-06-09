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
│   ├── question3_01_sumtable/
│   └── question3_02_visuals/
│
└── question_4_AI/
```

---

# Question 1 — SDTM DS Domain Creation

## Objective

Create an SDTM-compliant DS (Disposition) domain using the `{sdtm.oak}` package.

## Files

### `question_1_sdtm_01_create_ds_domain.R`

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

### `question_2_adam_01_create_adsl.R`

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

#### `question_3_tlg_01_create_ae_summary_table.R`

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

#### `question_3_tlg_01_create_ae_visualizations.R`

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
ClinicalTrialDataAgent
      ↓
OpenAI LLM
      ↓
Structured JSON Output
      ↓
Query Engine
      ↓
Results Summary
```

## Program Files

### `main.py`

Application entry point.

Responsibilities:

* Accepts user questions
* Calls the Clinical Trial Data Agent
* Displays structured outputs
* Executes dataset queries
* Returns results to the user

---

### `clinical_trial_data_agent.py`

Core AI agent implementation.

Responsibilities:

* Creates prompts for the LLM
* Sends questions to OpenAI
* Parses structured responses
* Coordinates query execution

---

### `query_engine.py`

Clinical data query engine.

Responsibilities:

* Loads the adverse event dataset
* Applies filtering logic
* Returns matching records

---

### `schema.py`

Structured output schema definition.

Responsibilities:

* Defines expected JSON structure
* Standardizes LLM responses
* Validates parsed outputs

Example:

```json
{
  "target_column": "AETERM",
  "filter_value": "HEADACHE"
}
```

---

### `ae_dataset.csv`

Sample adverse event dataset used by the AI assistant.

---

## Running the AI Assistant

### Prerequisites

Install required Python packages:

```bash
pip install -r requirements.txt
```

### Environment Setup

Create a `.env` file inside the `question_4_AI` directory:

```text
OPENAI_API_KEY=YOUR_API_KEY_HERE
```

Example:

```text
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> **Note:** The `.env` file is intentionally excluded from the repository and should never be committed to GitHub.

### Run the Application

Navigate to the AI assistant folder:

```bash
cd question_4_AI
```

Run the application:

```bash
python ClinicalTrialDataAgent.py
```
### Customizing Example Questions

The application includes a list of predefined example questions for demonstration purposes.

To add or modify example questions, open:

```text
ClinicalTrialDataAgent.py
```

Locate the following section:

```python
questions = [
    "Which subjects experienced severe headache adverse events?",
    ...
]
```

Add additional questions to the list as needed. The application will process each question through the complete workflow:

1. Natural language question
2. LLM interpretation
3. Structured JSON generation
4. Clinical dataset query execution
5. Results summary

This allows users to easily test additional clinical data queries without modifying the core application logic.

### Example Query

```text
Which subjects experienced severe headache adverse events?
```

### Example Structured Output

```json
{
  "target_column": "AETERM",
  "filter_value": "HEADACHE"
}
```

### Example Result

```text
Matching Subjects:
SUBJ001
SUBJ005
SUBJ021

Summary:
3 subjects experienced headache adverse events.
```

## Output

* PDF file for Final Output
* Structured JSON interpretation
* Matching subject IDs
* Query results summary

---

# Technologies Used

## Clinical Standards

* CDISC SDTM
* CDISC ADaM

## R

* sdtm.oak
* admiral
* dplyr
* tidyr
* gt
* ggplot2

## Python

* pandas
* LangChain
* OpenAI API
* python-dotenv

---

# Reproducibility

Each question folder contains:

* Source code
* Generated outputs
* Execution logs

The included logs demonstrate successful execution and support reproducibility of all deliverables. The workflow follows a traceable process from source data to final outputs.
