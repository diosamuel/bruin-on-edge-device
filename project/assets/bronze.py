"""@bruin
name: bronze.metrics
type: python
connection: duckdb-default

materialization:
  type: table
@bruin"""

import json
from pathlib import Path

import pandas as pd

METRICS_PATH = Path(__file__).resolve().parents[2] / "metrics.jsonl"


def materialize():
    rows = []
    skipped = 0
    with METRICS_PATH.open(encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                skipped += 1

    if skipped:
        print(f"bronze.metrics: skipped {skipped} malformed line(s) in {METRICS_PATH.name}")

    df = pd.DataFrame(rows)
    timestamps = df["timestamp"].str.replace("Z", "", regex=False)
    df["timestamp"] = pd.to_datetime(timestamps, format="ISO8601", utc=True)
    return df
