# Methodology

## Workflow

```
Raw zip (read-only) → understanding → data-quality checks → cleaning (logged) → feature engineering
→ EDA → KPIs → vintage trends → segments (grade, term, purpose, borrower, region, policy, high-value)
→ SQL (PostgreSQL, 23 queries) → reconciliation (SQL = Python) → Excel workbook → Power BI → insights
```

## KPI definitions (identical in Python, SQL, Excel and Power BI)

| KPI | Definition |
|---|---|
| Loans / Funded amount | count of loans / sum of `funded_amnt` |
| Funding rate | sum(`funded_amnt`) ÷ sum(`loan_amnt`) |
| Resolved loan | outcome Fully Paid or Charged Off |
| Default rate | charged-off loans ÷ resolved loans |
| Net return | sum(`total_pymnt`) ÷ sum(`funded_amnt`) − 1, resolved loans |
| Net principal loss | `funded_amnt` − `total_rec_prncp` − `recoveries`, charged-off loans |
| Loss given default (LGD) | net principal loss ÷ funded amount of charged-off loans |
| Policy exception share | loans with `meets_credit_policy` = False ÷ all loans |
| High-value customer | annual income ≥ 90th percentile ($116,736) |
| Risk flags (0–5) | DTI ≥ 20, utilisation ≥ 75%, 3+ inquiries, 60-month term, small-business purpose |

## Why like-for-like comparisons matter

Total return grows with how long money is lent, and lower grades have more 60-month loans. Grade returns are therefore
also compared **within 36-month loans only**, which reveals that grades F–G returned far less than D–E.

## Validation

* SQL vs Python: 60/60 KPIs match (`reports/sql_python_reconciliation.md`).
* LendingClub control total, amortisation formula and payment-component checks (see `docs/data_cleaning.md`).
* Excel: the Summary sheet compares every KPI with the notebook (✓/✗); every formula was recalculated and checked (`reports/excel_verification.md`).

## Limitations

* Only approved loans → no approval/rejection analysis; no FICO score, age or gender in this file.
* 2007–2011 includes the financial crisis; risk levels may differ in other periods.
* Recent vintages (2011) still had active loans in the Dec-2015 extract.
* Correlations are not causation; grades are LendingClub's own risk model, so grade already summarises many factors.
