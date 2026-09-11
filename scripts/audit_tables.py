"""Reconstruct reservation contrasts from printed tables, without microdata."""

import csv
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def contrasts(current, previous, interaction):
    return {
        "interaction": interaction,
        "both_vs_previous_only": current + interaction,
        "both_vs_current_only": previous + interaction,
        "both_vs_neither": current + previous + interaction,
        "current_only_vs_neither": current,
        "previous_only_vs_neither": previous,
    }


def repeated_counts(rows):
    result = []
    for row in rows:
        current = int(row["current"]) - int(row["current_only"])
        previous = int(row["previous"]) - int(row["previous_only"])
        if current != previous or current < 0:
            raise ValueError(f"Inconsistent reservation counts: {row['state']}")
        result.append({**row, "both": current})
    return result


def read_csv(path):
    with path.open(newline="") as handle:
        return list(csv.DictReader(handle))


def main():
    manifest = json.loads((ROOT / "sources/manifest.json").read_text())
    for name, info in manifest["transcriptions"].items():
        observed = hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
        if observed != info["sha256"]:
            raise ValueError(f"Transcription changed; reverify source: {name}")

    estimates = []
    for row in read_csv(ROOT / "data/table5.csv"):
        terms = [float(row[key]) for key in ("current", "previous", "interaction")]
        for contrast, value in contrasts(*terms).items():
            estimates.append(
                {
                    "panel": row["panel"],
                    "outcome": row["outcome"],
                    "contrast": contrast,
                    "estimate": value,
                    "units": row["units"],
                    "n": row["n"],
                    "standard_error": (
                        row["se_interaction"] if contrast == "interaction" else ""
                    ),
                }
            )
    output = ROOT / "output"
    output.mkdir(exist_ok=True)
    with (output / "contrasts.csv").open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=estimates[0])
        writer.writeheader()
        writer.writerows(estimates)

    counts = repeated_counts(read_csv(ROOT / "data/table_a25.csv"))
    summary = {
        "method": "Arithmetic from rounded author-manuscript tables; no regression run",
        "repeated_villages": sum(row["both"] for row in counts),
        "states_with_repeated_villages": sum(row["both"] > 0 for row in counts),
        "early_adopter_repeated_villages": sum(
            row["both"]
            for row in counts
            if int(row["first_quota_year_as_printed"]) <= 1994
        ),
        "current_reserved_villages": sum(int(row["current"]) for row in counts),
        "repeated_by_state": {row["state"]: row["both"] for row in counts},
        "expm1_minus_1_1_percent": 100 * math.expm1(-1.1),
        "log_conversion_scope": (
            "Multiplicative transformed-outcome interaction only; "
            "not a correction to mean bribe expenditure. Zero coding is unknown."
        ),
        "covariance_status": "Unavailable; no uncertainty computed for sums",
    }
    (output / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")

    labels = {
        "interaction": "Interaction (reported coefficient)",
        "both_vs_previous_only": "Both terms vs previous only",
        "both_vs_current_only": "Both terms vs current only",
        "both_vs_neither": "Both terms vs neither",
    }
    table = ["| Comparison | Difference, percentage points |", "|:--|--:|"]
    for row in estimates:
        if (
            row["panel"] == "B"
            and row["outcome"] == "any_bribe"
            and row["contrast"] in labels
        ):
            table.append(f"| {labels[row['contrast']]} | {100 * row['estimate']:.2f} |")
    table.extend(
        [
            "",
            "Table A25 implies "
            f"**{summary['repeated_villages']} twice-reserved villages in "
            f"{summary['states_with_repeated_villages']} states**, including "
            f"{summary['early_adopter_repeated_villages']} "
            "in its early-adopter sample.",
        ]
    )
    readme = ROOT / "README.md"
    start, end = "<!-- TABLE_AUDIT_START -->", "<!-- TABLE_AUDIT_END -->"
    text = readme.read_text()
    before, rest = text.split(start)
    _, after = rest.split(end)
    readme.write_text(before + start + "\n" + "\n".join(table) + "\n" + end + after)
    print("Verified transcriptions; wrote 48 contrasts and reservation-cell counts.")


if __name__ == "__main__":
    main()
