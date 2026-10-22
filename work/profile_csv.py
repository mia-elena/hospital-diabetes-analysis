"""Profile a CSV for Big Data Assignment 1, Part 1.

Usage:  python3 work/profile_csv.py data/diabetic_data.csv
Writes  work/profile.md: rows, columns, each attribute's
type, distinct values, missing/unknown values ('?', blank, 'None'),
and columns that could be keys.
"""
import sys
from pathlib import Path
import pandas as pd

IGNORE = """metformin repaglinide nateglinide chlorpropamide glimepiride acetohexamide
glipizide glyburide tolbutamide pioglitazone rosiglitazone acarbose miglitol troglitazone
tolazamide examide citoglipton insulin glyburide-metformin glipizide-metformin
glimepiride-pioglitazone metformin-rosiglitazone metformin-pioglitazone change""".split()
MISSING = {"?", "", "None", "Unknown/Invalid", "NULL", "NaN"}

path = Path(sys.argv[1] if len(sys.argv) > 1 else "data/diabetic_data.csv")
df = pd.read_csv(path, dtype=str, keep_default_na=False)
n = len(df)

lines = [f"# Profile of `{path.name}`", "",
         f"- Rows: **{n:,}**",
         f"- Columns: **{df.shape[1]}** ({df.shape[1] - len([c for c in IGNORE if c in df])} after dropping the {len([c for c in IGNORE if c in df])} columns the assignment says to ignore)", "",
         "| # | Column | Looks like | Distinct | Missing/unknown | Examples |",
         "|---|---|---|---|---|---|"]
keys = []
for i, col in enumerate(df.columns, 1):
    s = df[col]
    miss = s.isin(MISSING).sum()
    distinct = s.nunique()
    numeric = pd.to_numeric(s[~s.isin(MISSING)], errors="coerce").notna().all()
    kind = "number" if numeric else "text"
    ex = ", ".join(s[~s.isin(MISSING)].drop_duplicates().head(3))
    flag = " *(ignored)*" if col in IGNORE else ""
    miss_txt = f"{miss:,} ({miss / n:.1%})" if miss else "0"
    lines.append(f"| {i} | `{col}`{flag} | {kind} | {distinct:,} | {miss_txt} | {ex} |")
    if distinct == n and miss == 0:
        keys.append(col)

lines += ["", "## Possible keys", ""]
lines += [f"- `{k}` is unique on every row, so it can be a primary key." for k in keys] or ["- No single column is unique on every row."]
for col in df.columns:
    if col.endswith("_nbr") or col.endswith("_id"):
        d = df[col].nunique()
        if d < n:
            lines.append(f"- `{col}` has {d:,} distinct values across {n:,} rows, so it repeats: an identifier for another entity (foreign key candidate).")

lines += ["", "## Columns with missing or unknown values", ""]
for col in df.columns:
    miss = df[col].isin(MISSING).sum()
    if miss and col not in IGNORE:
        vals = sorted(set(df[col][df[col].isin(MISSING)]))
        lines.append(f"- `{col}`: {miss:,} rows ({miss / n:.1%}), written as {', '.join(repr(v) for v in vals)}")

out = Path(__file__).resolve().parent / "profile.md"
out.write_text("\n".join(lines) + "\n")
print(f"Wrote {out}  ({n:,} rows x {df.shape[1]} columns)")
