# Excel workbook verification

Workbook: [`excel/loan_portfolio_analysis.xlsx`](../excel/loan_portfolio_analysis.xlsx) · 383,755 formulas · 9 charts · checked 22 Oct 2026

**Result: 46 of 46 checks passed.**

## How the workbook was checked

1. **Structure** — the file was opened with `openpyxl` to confirm the Excel Tables, named ranges, PivotTables,
   conditional-formatting rules, charts and the Excel functions used.
2. **Full recalculation** — every formula was recalculated from scratch in LibreOffice Calc (headless) and the results
   were compared with the values stored in the file.
3. **Independent numbers** — the recalculated results were compared with values computed separately in pandas from the
   cleaned CSV files, the notebook KPIs (`reports/kpi_summary.json`) and the SQL results (`sql/results/`).

The recalculation was done in **LibreOffice, not Microsoft Excel**. The file is a standard `.xlsx` built for Excel
2019 / 2021 / 365; the PivotTables are set to refresh when the file is opened.

## Checks

| # | Check | Result |
|---|---|---|
| 1 | defined names present | PASS |
| 2 | Excel tables present | PASS |
| 3 | pivot tables parsed by openpyxl | PASS |
| 4 | conditional formatting rules present | PASS |
| 5 | analysis sheets contain formulas | PASS |
| 6 | uses SUMIFS | PASS |
| 7 | uses COUNTIFS | PASS |
| 8 | uses AVERAGEIFS | PASS |
| 9 | uses VLOOKUP | PASS |
| 10 | uses IFS | PASS |
| 11 | uses IF | PASS |
| 12 | uses IFERROR | PASS |
| 13 | uses PERCENTILE.INC | PASS |
| 14 | uses YEAR | PASS |
| 15 | uses OR | PASS |
| 16 | uses ROWS | PASS |
| 17 | charts present | PASS |
| 18 | analysis formulas: no errors after LibreOffice recalculation | PASS |
| 19 | analysis formulas: recalculated = cached values | PASS |
| 20 | Loans: row formulas recalculated = pandas values | PASS |
| 21 | Summary loans = rows in cleaned data | PASS |
| 22 | Summary funded = pandas | PASS |
| 23 | Summary average loan = pandas | PASS |
| 24 | Summary average rate = pandas | PASS |
| 25 | Summary default rate = pandas | PASS |
| 26 | Summary net return = pandas | PASS |
| 27 | Summary principal lost = pandas | PASS |
| 28 | Summary policy exceptions = pandas | PASS |
| 29 | Summary ✓ checks all pass | PASS |
| 30 | Summary outcome mix = pandas | PASS |
| 31 | Summary outcome shares = pandas | PASS |
| 32 | Grade_Analysis loans, default rate, 36m return = Python | PASS |
| 33 | Term_Grade matrix = Python (14 cells) | PASS |
| 34 | Purpose loans & default rate = Python | PASS |
| 35 | Income bands default rate = Python | PASS |
| 36 | P90 income threshold = Python | PASS |
| 37 | High-value default & return = Python | PASS |
| 38 | Region rows = SQL Q11 (loans, default rate) | PASS |
| 39 | State loan counts = pandas (51 states incl. zero) | PASS |
| 40 | North Dakota shows 0 loans (LEFT JOIN logic) | PASS |
| 41 | Vintage loans, funded, default rate = Python | PASS |
| 42 | Monthly running total ends at total funded | PASS |
| 43 | Monthly table covers 55 months | PASS |
| 44 | Risk flag rows = SQL Q23 | PASS |
| 45 | Pivot 1 grade × outcome counts = pandas | PASS |
| 46 | Pivot 2 funded by purpose = pandas | PASS |
