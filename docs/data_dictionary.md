# Data dictionary

## Raw file (`data/raw/LoanStats3a.csv.zip`)

42,535 loans × 74 columns as published by LendingClub. 21 columns are completely empty for
2007–2011 loans (they describe products and bureau fields added later) and are dropped. Text formats in the raw file:
rates as `" 10.65%"`, terms as `" 36 months"`, employment as `"10+ years"`, dates as `"Dec-2011"`.

## Cleaned table — `data/cleaned/loans_clean.csv` (42,535 rows × 58 columns, one row per loan / borrower)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `id` | LendingClub loan id | integer | 1077501 | Primary key |
| `member_id` | Borrower id | integer | 1296599 | Each borrower appears once |
| `issue_d` | Month the loan was issued | date | 2011-12-01 | Vintage / trend analysis |
| `issue_year` | Issue year | integer | 2011 | Vintage |
| `issue_quarter` | Issue quarter (e.g. 2011Q4) | text | 2011Q4 | Quarterly trend |
| `issue_month` | Issue month (YYYY-MM) | text | 2011-12 | Monthly trend |
| `loan_amnt` | Amount applied for ($) | decimal | 5000.0 | Demand |
| `funded_amnt` | Amount committed to the loan ($) | decimal | 5000.0 | Exposure |
| `funded_amnt_inv` | Part funded by investors ($) | decimal | 4975.0 | Investor appetite |
| `funding_gap` | loan_amnt − funded_amnt | decimal | 0.0 | Unmet demand |
| `term_months` | Loan term: 36 or 60 months | integer | 36 | Tenure |
| `int_rate` | Annual interest rate (%) | decimal | 10.65 | Price of risk |
| `installment` | Monthly payment ($) | decimal | 162.87 | Affordability |
| `grade` | LendingClub grade A–G | text | B | Risk tier (A = safest) |
| `sub_grade` | Sub-grade A1–G5 | text | B2 | Finer risk tier |
| `purpose` | Loan purpose (cleaned label) | text | Credit card | Product use |
| `title` | Loan title typed by the borrower | text | Computer | Free text |
| `emp_title` | Employer / job title (lower case) | text | ryder | Free text |
| `emp_length` | Employment length text ('Unknown' if missing) | text | 10+ years | Stability |
| `emp_length_years` | Employment length 0–10 | decimal | 10.0 | Stability (numeric) |
| `home_ownership` | RENT / MORTGAGE / OWN / OTHER | text | RENT | Demographic |
| `annual_inc` | Self-reported annual income ($) | decimal | 24000.0 | Capacity to pay |
| `income_band` | Income band | text | <30K | Segmentation |
| `is_high_income` | Top 10% income | boolean | False | High-value customer flag |
| `verification_status` | Income verification status | text | Verified | Due diligence |
| `addr_state` | Borrower state | text | AZ | Regional analysis |
| `region` | US Census region | text | West | Regional roll-up |
| `zip_code` | First 3 digits of zip | text | 860xx | Location (anonymised) |
| `dti` | Debt-to-income ratio (%) | decimal | 27.65 | Leverage |
| `dti_band` | DTI band | text | 25–30 | Segmentation |
| `delinq_2yrs` | 30+ day delinquencies in last 2 years | decimal | 0.0 | Credit behaviour |
| `inq_last_6mths` | Credit inquiries in last 6 months | decimal | 1.0 | Credit hunger |
| `open_acc` | Open credit lines | decimal | 3.0 | Credit profile |
| `pub_rec` | Derogatory public records | decimal | 0.0 | Credit behaviour |
| `revol_bal` | Revolving balance ($) | decimal | 13648.0 | Debt |
| `revol_util` | Revolving utilisation (%) | decimal | 83.7 | Credit stress |
| `revol_util_band` | Utilisation band | text | 75–100% | Segmentation |
| `total_acc` | Total credit lines ever | decimal | 9.0 | Credit depth |
| `earliest_cr_line` | Date of first credit line | date | 1985-01-01 | Credit history |
| `credit_history_years` | Years of credit history at issue | decimal | 26.9 | Experience with credit |
| `loan_amount_band` | Loan amount band | text | 5–10K | Segmentation |
| `installment_to_income` | Yearly installments ÷ income | decimal | 0.0814 | Affordability |
| `loan_status` | Status in Dec 2015 (policy prefix removed) | text | Fully Paid | Raw outcome |
| `meets_credit_policy` | Meets the current credit policy | boolean | True | Policy exception flag |
| `outcome` | Fully Paid / Charged Off / Active | text | Fully Paid | Outcome used in KPIs |
| `is_resolved` | Loan finished (paid or charged off) | boolean | True | Default-rate denominator |
| `is_bad` | Charged off (incl. 'Default') | boolean | False | Default-rate numerator |
| `total_pymnt` | All payments received ($) | decimal | 5861.071414249 | Cash returned |
| `total_rec_prncp` | Principal repaid ($) | decimal | 5000.0 | Cash returned |
| `total_rec_int` | Interest paid ($) | decimal | 861.07 | Revenue |
| `total_rec_late_fee` | Late fees paid ($) | decimal | 0.0 | Revenue |
| `recoveries` | Recovered after charge-off ($) | decimal | 0.0 | Loss mitigation |
| `collection_recovery_fee` | Collection fee on recoveries ($) | decimal | 0.0 | Cost of recovery |
| `out_prncp` | Outstanding principal ($) | decimal | 0.0 | Open exposure |
| `last_pymnt_d` | Last payment month | date | 2015-01-01 | Payment history |
| `last_pymnt_amnt` | Last payment amount ($) | decimal | 171.62 | Payment history |
| `net_return` | total_pymnt ÷ funded_amnt − 1 (resolved loans) | decimal | 0.172214 | Profitability |
| `net_principal_loss` | funded − principal repaid − recoveries (charged-off) | decimal | 0.0 | Credit loss |

## Reference table — `data/cleaned/dim_state.csv` (51 rows)

| Column | Description | Data Type | Example | Business Meaning |
|---|---|---|---|---|
| `state_code` | 2-letter state code | text | CA | Joins to `addr_state` |
| `state_name` | State name | text | California | Labels / map |
| `region` | US Census Bureau region | text | West | Regional roll-up |

`dim_state` is reference data added by the analyst (US Census Bureau regions), not part of the LendingClub file.
