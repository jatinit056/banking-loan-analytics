# Data cleaning

All cleaning happens in `notebooks/banking_loan_analysis.ipynb` (sections 5–12). The raw zip is never modified; the
notebook writes `data/cleaned/loans_clean.csv` and `dim_state.csv`. Every step is logged in `reports/cleaning_log.csv`;
data-quality checks are in `reports/data_quality_checks.csv`. SQL and Python results reconcile (60/60 checks).

## 1. Parsing problems in the raw file

| Issue | Rows | Decision |
|---|---|---|
| Title line above the header (`Notes offered by Prospectus…`) | 1 | Skipped (`skiprows=1`) |
| Separator row "Loans that do not meet the credit policy" + 2 footer total rows | 3 | Removed (not loans) |

## 2. Missing values

| Column | Missing | Decision |
|---|---|---|
| 21 columns (joint applications, newer bureau fields) | 100% | Dropped |
| `mths_since_last_record`, `mths_since_last_delinq` | mostly empty | Dropped: blank means "never had one", not unknown; delinquencies are covered by `delinq_2yrs` and `pub_rec` |
| `emp_length` | 1112 | Kept as **"Unknown"** — it turned out to be a risk signal (23.2% default vs 15.5%) |
| `annual_inc` | 4 | Kept; excluded from income analysis |
| `revol_util` | 90 | Kept; excluded from utilisation analysis |
| Credit-history fields (`earliest_cr_line`, `delinq_2yrs`, `inq_last_6mths`, …) | 29 | Kept (same loans) |
| `next_pymnt_d` | finished loans | Dropped (only meaningful for active loans) |

## 3. Duplicates

No duplicated rows, loan ids or borrower ids — each row is one loan and one borrower.

## 4. Invalid values and consistency checks (all passed)

| Check | Result |
|---|---|
| Sum of `loan_amnt` = LendingClub control total in the file footer | $471,701,350 — matches |
| Installment follows the amortisation formula (±$1) | 99.97% of loans |
| `funded_amnt` > `loan_amnt` | 0 loans; 1,997 loans partly funded |
| `total_pymnt` = principal + interest + late fees + recoveries (±$0.02) | 100.00% of loans |
| Loans with recoveries that are not charged off | 0 |
| Interest rate / DTI ranges | 5.42 – 24.59% / 0.0 – 29.99 (within LendingClub limits) |

## 5. Type and date conversion

* `int_rate`, `revol_util`: `" 10.65%"` → `10.65` (number).
* `term`: `" 36 months"` → `36` (`term_months`).
* `emp_length`: `"10+ years"` → 10, `"< 1 year"` → 0 (`emp_length_years`); text kept for labels.
* `issue_d`, `earliest_cr_line`, `last_pymnt_d`, `last_credit_pull_d`: `"Dec-2011"` → `2011-12-01`.
* Integer columns with gaps stored as nullable integers.

## 6. Standardisation

| What | Rows | Decision |
|---|---|---|
| `loan_status` "Does not meet the credit policy. Status: …" | 2749 | Split into `meets_credit_policy` (False) + the plain status |
| `home_ownership` = NONE | 8 | Merged into OTHER |
| `purpose` labels | all | `debt_consolidation` → "Debt consolidation" |
| `emp_title` | all | Trimmed and lower-cased (free text, very messy: 28,926 distinct values) |
| Single-value and helper columns (`policy_code`, `application_type`, `url`, `desc`, …) | — | Dropped (30 columns dropped in total) |

## 7. Outliers

Self-reported income goes up to $6,000,000; 2,032 borrowers are above
the IQR fence ($146,250). They are **kept** (plausible, and removing them would bias the portfolio);
analysis uses the median and income bands, which are not distorted by a few large values.

## 8. Derived columns

`outcome`, `is_resolved`, `is_bad`, `issue_year/quarter/month`, `credit_history_years`, `funding_gap`, `net_return`,
`net_principal_loss`, `installment_to_income`, `income_band`, `dti_band`, `loan_amount_band`, `revol_util_band`,
`region` (US Census), `is_high_income` (top 10% income ≥ $116,736). Definitions: `docs/methodology.md`.

## 9. Assumptions

1. **"Default" status (1 loan, 121+ days late) is counted as charged off.**
2. **Active loans** (Current, In Grace Period, Late) are excluded from default rates — their outcome is unknown.
   9.8% of 2011 loans were still active, so the 2011 vintage default rate is read with care.
3. **Net return** is total (not annualised) and ignores LendingClub fees and the time value of money.
4. **Approval / rejection rates cannot be calculated** — the file contains only approved and issued loans.
