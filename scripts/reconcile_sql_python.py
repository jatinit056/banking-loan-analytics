"""Reconcile the SQL results (sql/results/*.csv) with the Python notebook KPIs (reports/kpi_summary.json).

Run after the notebook and scripts/run_sql_queries.py:
    python scripts/reconcile_sql_python.py
Writes reports/sql_python_reconciliation.md; exit code 1 if any check fails.
"""
import json
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
kpi = json.loads((ROOT / "reports" / "kpi_summary.json").read_text())
q = {f.stem: pd.read_csv(f) for f in sorted((ROOT / "sql" / "results").glob("Q*.csv"))}
checks = []


def check(name, sql_value, python_value, tolerance=0.0):
    ok = abs(float(sql_value) - float(python_value)) <= tolerance
    checks.append((name, sql_value, round(float(python_value), 4), "PASS" if ok else "FAIL"))


q01 = q["Q01"].iloc[0]
check("Loans (Q01)", q01["loans"], kpi["loans"])
check("Requested amount $ (Q01)", q01["requested_amount"], kpi["requested_amount"], 0.01)
check("Funded amount $ (Q01)", q01["funded_amount"], kpi["funded_amount"], 0.01)
check("Funding rate % (Q01)", q01["funding_rate_pct"], round(kpi["funding_rate"] * 100, 2), 0.01)
check("Average loan $ (Q01)", q01["avg_loan_amount"], round(kpi["avg_loan_amount"], 2), 0.01)
check("Average interest rate % (Q01)", q01["avg_int_rate_pct"], round(kpi["avg_int_rate"], 2), 0.01)
check("60-month share % (Q01)", q01["share_60_month_pct"], round(kpi["share_60_month"] * 100, 2), 0.01)
check("Median income $ (Q01)", q01["median_annual_income"], kpi["median_income"], 0.01)

q07 = q["Q07"].set_index("grade")
for g, v in kpi["grade_default_rate"].items():
    check(f"Default rate grade {g} % (Q07)", q07.loc[g, "default_rate_pct"], round(v * 100, 2), 0.01)
for g, v in kpi["grade_net_return"].items():
    check(f"Net return grade {g} % (Q07)", q07.loc[g, "net_return_pct"], round(v * 100, 2), 0.01)
check("Charged-off loans (Q07 total)", q07["charged_off"].sum(), kpi["charged_off_loans"])
check("Resolved loans (Q07 total)", q07["resolved_loans"].sum(), kpi["resolved_loans"])

q08 = q["Q08"].set_index("grade")
for key, v in kpi["term_grade_default"].items():
    g, t = key.split("_")
    check(f"Default rate {g} {t}m % (Q08)", q08.loc[g, f"default_rate_{t}m_pct"], round(v * 100, 2), 0.01)

q11 = q["Q11"].set_index("region")
for r, v in kpi["region_default_rate"].items():
    check(f"Default rate {r} % (Q11)", q11.loc[r, "default_rate_pct"], round(v * 100, 2), 0.01)
    check(f"Funded share {r} % (Q11)", q11.loc[r, "pct_of_funded"], round(kpi["region_funded_share"][r] * 100, 2), 0.01)

q13 = q["Q13"].set_index("customer_group")
check("Top-10% income threshold $ (Q13)", q13.loc["Top 10% income", "p90_income_threshold"], kpi["income_p90"], 0.01)
check("Default rate top-10% income % (Q13)", q13.loc["Top 10% income", "default_rate_pct"],
      round(kpi["high_income_default_rate"] * 100, 2), 0.01)

q14 = q["Q14"].set_index("policy_group")
for grp, v in kpi["policy_default_rate"].items():
    check(f"Default rate '{grp}' % (Q14)", q14.loc[grp, "default_rate_pct"], round(v * 100, 2), 0.01)

q21 = q["Q21"].set_index("issue_year")
for y, v in kpi["vintage_default_rate"].items():
    check(f"Default rate vintage {y} % (Q21)", q21.loc[int(y), "default_rate_pct"], round(v * 100, 2), 0.01)

q22 = q["Q22"]
check("Net principal lost $ (Q22 total)", q22["net_principal_loss"].sum(), kpi["principal_lost"], 0.05)
check("Recoveries $ (Q22 total)", q22["recoveries"].sum(), kpi["recoveries"], 0.05)

q09 = q["Q09"].iloc[0]
check(f"Worst state ({q09['state_code']}) default rate % (Q09)", q09["default_rate_pct"],
      round(kpi["worst_state_default_rate"] * 100, 2), 0.01)
checks.append(("Worst state code (Q09)", q09["state_code"], kpi["worst_state"],
               "PASS" if q09["state_code"] == kpi["worst_state"] else "FAIL"))
q10 = q["Q10"]
zero = sorted(q10.loc[q10["loans"] == 0, "state_code"].tolist())
checks.append(("States with no loans (Q10)", ", ".join(zero), ", ".join(kpi["missing_states"]),
               "PASS" if zero == kpi["missing_states"] else "FAIL"))

report = ["# SQL vs Python reconciliation", "",
          "Each KPI was calculated independently in PostgreSQL (`sql/analysis_queries.sql`) and in pandas (notebook). "
          "A check passes when both agree (money within $0.05, percentages within 0.01 points).", "",
          "| Check | SQL | Python | Result |", "|---|---|---|---|"]
report += [f"| {n} | {s} | {p} | {r} |" for n, s, p, r in checks]
passed = sum(c[3] == "PASS" for c in checks)
report += ["", f"**{passed} of {len(checks)} checks passed.**"]
(ROOT / "reports" / "sql_python_reconciliation.md").write_text("\n".join(report) + "\n", encoding="utf-8")
print("\n".join(report[-3:]))
for c in checks:
    if c[3] != "PASS":
        print("FAIL:", c)
raise SystemExit(0 if passed == len(checks) else 1)
