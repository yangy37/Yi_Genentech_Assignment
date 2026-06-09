import pandas as pd

from dotenv import load_dotenv
from agent import ClinicalTrialDataAgent
from reportlab.platypus import SimpleDocTemplate, Paragraph, PageBreak, Table, TableStyle, Spacer
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
import json

load_dotenv()

ae = pd.read_csv("data/adae.csv")

agent = ClinicalTrialDataAgent(ae)

questions = [

    "Give me the subjects who had Adverse events of Moderate severity.",

    "Which subjects had Headache adverse events?",

    "Show me subjects with Cardiac adverse events.",

    "Show me patients with severe adverse events.",

    "Which subjects experienced mild toxicity?",

    "Show me all serious adverse events."
]

summary_rows = []

for question in questions:

    result = agent.query(question)

    result["question"] = question

    summary_rows.append(result)

    print("=" * 80)
    print("Question:")
    print(result["question"])

    print("\nLogic Flow:")
    print("1. Prompt: User question and AE schema were sent to the LLM.")
    print(f"2. Parse: LLM returned JSON: {result['llm_raw_output']}")
    print(
        f"3. Execute: Pandas filtered {result['target_column']} "
        f"for value {result['matched_dataset_value']}."
    )

    print("\nMapped Column:")
    print(result["target_column"])

    print("\nLLM Filter Value:")
    print(result["llm_filter_value"])

    print("\nMatched Dataset Value:")
    print(result["matched_dataset_value"])

    print("\nUnique Subject Count:")
    print(result["unique_subject_count"])

    print("\nFirst 10 Matching Subject IDs:")
    print(result["matching_subject_ids_preview"])

    print("\nAE Summary:")
    print(result["ae_summary_df"])

    print()




pdf = SimpleDocTemplate("question4_results.pdf")
styles = getSampleStyleSheet()
content = []

for result in summary_rows:

    content.append(Paragraph(f"<b>Question:</b> {result['question']}", styles["Normal"]))
    content.append(
        Paragraph(
            f"<b>Structured JSON:</b> "
            f"{json.dumps(result['parsed_json'])}",
            styles["Normal"]
        )
    )
    content.append(Paragraph(f"<b>Mapped Column:</b> {result['target_column']}", styles["Normal"]))
    content.append(Paragraph(f"<b>LLM Filter Value:</b> {result['llm_filter_value']}", styles["Normal"]))
    content.append(Paragraph(f"<b>Matched Dataset Value:</b> {result['matched_dataset_value']}", styles["Normal"]))
    content.append(Paragraph(f"<b>Unique Subject Count:</b> {result['unique_subject_count']}", styles["Normal"]))

    content.append(Spacer(1, 12))

    df = result["ae_summary_df"].head(20)

    content.append(
        Paragraph(
            f"Showing first 20 records of {len(result['ae_summary_df'])} matching AE records.",
            styles["Normal"]
        )
    )

    table_data = [df.columns.tolist()] + df.values.tolist()

    table = Table(table_data)

    table.setStyle(
        TableStyle([
            ("GRID", (0, 0), (-1, -1), 0.5, colors.black),
            ("BACKGROUND", (0, 0), (-1, 0), colors.lightgrey),
            ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("FONTSIZE", (0, 0), (-1, -1), 7),
        ])
    )
    content.append(table)
    content.append(PageBreak())



pdf.build(content)

print("PDF generated: question4_results.pdf")
