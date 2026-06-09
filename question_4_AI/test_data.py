import pandas as pd

df = pd.read_csv("data/adae.csv")

print(df.shape)
print(df.columns.tolist())