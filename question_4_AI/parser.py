import json
import pandas as pd
from dotenv import load_dotenv
from openai import OpenAI


load_dotenv()
client = OpenAI()


class ClinicalTrialDataAgent:
    def __init__(self, dataframe):
        self.df = dataframe

        self.schema = """
        AE dataset schema:
        - USUBJID: unique subject ID
        - AESEV: adverse event severity/intensity, such as MILD, MODERATE, SEVERE
        - AETERM: adverse event term, such as Headache, Nausea
        - AESOC: system organ class/body system, such as Cardiac disorders, Skin disorders
        - AESER: serious adverse event flag, Y or N
        """

    def parse_question(self, question):
        prompt = f"""
        You are a clinical trial data assistant.

        Based on this schema:
        {self.schema}

        Convert the user's question into JSON only.

        Required JSON format:
        {{
            "target_column": "",
            "filter_value": ""
        }}

        Mapping guidance:
        - severity/intensity -> AESEV
        - condition/symptom/adverse event term -> AETERM
        - body system/system organ class -> AESOC
        - serious adverse event -> AESER with value Y

        User question:
        {question}
        """

        response = client.responses.create(
            model="gpt-4.1-mini",
            input=prompt
        )

        return json.loads(response.output_text)

    def query(self, question):
        parsed = self.parse_question(question)

        target_column = parsed["target_column"]
        filter_value = parsed["filter_value"]

        filtered = self.df[
            self.df[target_column]
            .astype(str)
            .str.contains(str(filter_value), case=False, na=False)
        ]

        subject_ids = sorted(filtered["USUBJID"].dropna().unique().tolist())

        return {
            "question": question,
            "target_column": target_column,
            "filter_value": filter_value,
            "unique_subject_count": len(subject_ids),
            "matching_subject_ids": subject_ids
        }


if __name__ == "__main__":

    ae = pd.read_csv("data/adae.csv")

    agent = ClinicalTrialDataAgent(ae)

    questions = [
        "Give me the subjects who had Adverse events of Moderate severity.",
        "Which subjects had Headache adverse events?",
        "Show me subjects with Cardiac adverse events."
    ]

    for question in questions:
        result = agent.query(question)

        print("=" * 80)
        print("Question:", result["question"])
        print("Mapped Column:", result["target_column"])
        print("Filter Value:", result["filter_value"])
        print("Unique Subject Count:", result["unique_subject_count"])
        print("Matching Subject IDs:", result["matching_subject_ids"])

