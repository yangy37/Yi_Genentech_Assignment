import json
import re
from openai import OpenAI

from prompt import SYSTEM_PROMPT


class ClinicalTrialDataAgent:

    def __init__(self, dataframe):
        self.df = dataframe
        self.client = OpenAI()

        self.allowed_columns = {
            "AETERM", "AESOC", "AESEV", "AESER"
        }

    def ask_llm(self, question):

        response = self.client.responses.create(
            model="gpt-4.1-mini",
            input=f"""
{SYSTEM_PROMPT}

Return JSON only. No explanation.

User Question:
{question}
"""
        )

        return response.output_text

    def parse_llm_response(self, response_text):
        """
        Extract and validate JSON from LLM output.
        """

        match = re.search(r"\{.*\}", response_text, re.DOTALL)

        if not match:
            raise ValueError(f"No JSON found in LLM output: {response_text}")

        parsed = json.loads(match.group(0))

        target_column = parsed.get("target_column")
        filter_value = parsed.get("filter_value")

        if target_column not in self.allowed_columns:
            raise ValueError(f"Invalid target_column from LLM: {target_column}")

        if target_column not in self.df.columns:
            raise ValueError(f"{target_column} does not exist in dataset.")

        if not filter_value:
            raise ValueError("Missing filter_value from LLM output.")

        return target_column, filter_value

    def find_best_dataset_value(self, target_column, filter_value):
        """
        Match LLM value to real dataset values.

        Example:
        LLM: Cardiac
        Dataset: CARDIAC DISORDERS
        """

        unique_values = (
            self.df[target_column]
            .dropna()
            .astype(str)
            .unique()
            .tolist()
        )

        filter_lower = str(filter_value).lower()

        for value in unique_values:
            if filter_lower == value.lower():
                return value

        for value in unique_values:
            if filter_lower in value.lower():
                return value

        return filter_value

    def execute_query(self, target_column, filter_value):

        matched_value = self.find_best_dataset_value(
            target_column,
            filter_value
        )

        filtered = self.df[
            self.df[target_column]
            .astype(str)
            .str.contains(
                str(matched_value),
                case=False,
                na=False
            )
        ]

        subject_ids = sorted(
            filtered["USUBJID"]
            .dropna()
            .unique()
            .tolist()
        )

        ae_summary = (
            filtered[["USUBJID", "AETERM", "AESEV"]]
            .drop_duplicates()
            .sort_values(["USUBJID", "AETERM"])
        )

        return {
            "target_column": target_column,
            "llm_filter_value": filter_value,
            "matched_dataset_value": matched_value,
            "unique_subject_count": len(subject_ids),
            "matching_subject_ids": subject_ids,
            "matching_subject_ids_preview": subject_ids[:10],
            "ae_summary_df": ae_summary
        }

    def query(self, question):

        llm_output = self.ask_llm(question)

        target_column, filter_value = self.parse_llm_response(llm_output)

        result = self.execute_query(
            target_column,
            filter_value
        )

        result["question"] = question
        result["llm_raw_output"] = llm_output
        result["target_column"] = target_column
        result["llm_filter_value"] = filter_value
        result["parsed_json"] = {
            "target_column": target_column,
            "filter_value": filter_value
        }

        return result