# Raw data — source and provenance

| Item | Detail |
|---|---|
| Dataset | **LendingClub loan data — loans issued 2007–2011** (`LoanStats3a.csv`) |
| Original publisher | LendingClub Corporation (public loan statistics published on lendingclub.com) |
| On Kaggle | LendingClub loan data is republished on Kaggle in several datasets (for example *Lending Club Loan Data*, and *All Lending Club loan data* by wordsforthewise: https://www.kaggle.com/datasets/wordsforthewise/lending-club). This project uses the original 2007–2011 file. |
| Version | Extract dated **December 2015** (latest `last_pymnt_d` / `last_credit_pull_d` = Dec 2015; zip entry dated 2016-01-01) |
| Contents | 42,535 loans × 74 columns; one title line; a separator row before the 2,749 loans that do not meet the current credit policy; 2 footer rows with LendingClub's control totals |
| License / terms | Published by LendingClub for public use; follow LendingClub's terms if you reuse it. Used here for non-commercial, educational analysis. |
| Retrieved | 22 October 2026 |

## How the file was obtained and verified

Kaggle could not be reached from the environment used to build this project. The original LendingClub zip was
downloaded from a public GitHub mirror and checked against two other independent public copies of the same file:

| Copy | Source (commit) | Extract | Loan ids in common | Agreement on loan/borrower fields |
|---|---|---|---|---|
| **Used** | https://github.com/jsabrams/default_risk_prediction — `LoanStats3a.csv.zip` (`f73b176424d7e656202b0f5c583ff8d87ba6418e`) | Dec 2015 | — | — |
| Check 1 | https://github.com/h2oai/h2o-tutorials — `training/sessions/richmond/LoanStats3a.csv` (`050c224193391995b842c50709314a2d60c3ef0a`) | Jul 2015 | 42,535 of 42,535 | 99.99–100% per field |
| Check 2 | https://github.com/jananee009/Machine_Learning_Algorithms — `Loans/LoanStats3a.csv` (`59ed52e6cdea1cd178cfb2889bd8117d5ebfc101`) | Nov 2014 | 42,535 of 42,535 | 99.97–100% per field |

Fields compared: loan_amnt, funded_amnt, term, int_rate, grade, sub_grade, home_ownership, annual_inc, issue_d, purpose, addr_state, dti, zip_code. Only repayment fields (status, payments) differ between
extracts, as expected — later extracts contain more finished loans.

The file also passes LendingClub's own control total: the sum of `loan_amnt` equals the
"Total amount funded in policy code 1" printed at the end of the file ($471,701,350).

## File in this folder (kept exactly as downloaded — read-only)

| File | SHA-256 |
|---|---|
| `LoanStats3a.csv.zip` | `6e53451aca45fdc3265d01ea99e1543e3730c80a53b68cf098ef3db06ee3bc32` |
| `LoanStats3a.csv` (inside the zip) | `9c1f2adeb6313ce764b4ef675288a51d7389c20e88a527dce8f6c4b240e0e656` |

The zip is kept compressed (9.6 MB) because the unzipped CSV is 36 MB; the notebook reads it directly from the zip.
