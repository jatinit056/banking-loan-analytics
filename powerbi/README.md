# Power BI dashboard — Banking Customer & Loan Analytics (LendingClub)

[`Banking_LendingClub.pbix`](./Banking_LendingClub.pbix) · built in Power BI Desktop · 3 pages · 28 DAX measures · data imported from
`data/cleaned/` (loans 42,535 · dim_state 51 rows).

| Page | Screenshot |
|---|---|
| Executive Overview | [`screenshots/powerbi_page1_executive_overview.png`](../screenshots/powerbi_page1_executive_overview.png) |
| Detailed Analysis | [`screenshots/powerbi_page2_detailed_analysis.png`](../screenshots/powerbi_page2_detailed_analysis.png) |
| Business Insights | [`screenshots/powerbi_page3_business_insights.png`](../screenshots/powerbi_page3_business_insights.png) |

## What is on each page

* **Executive Overview** — 7 KPI cards (Loans issued, Funded amount, Average loan, Avg interest rate, Default rate (finished loans), Net return (finished), Principal lost); Line chart — Funded amount per month ($); Column chart — Default rate by grade; Bar chart — Funded amount by region ($); Bar chart — Loan outcome (number of loans).
* **Detailed Analysis** — Matrix (heat map) — Default rate: grade × term; Bar chart — Default rate by loan purpose; Bar chart — Top 10 states by funded amount ($); Column chart — Default rate by annual income; Column chart — Default rate by debt-to-income (DTI %); Bar chart — Default rate by home ownership.
* **Business Insights** — Column chart — Net return by grade — 36-month loans (finished); Column chart — Default rate by number of risk flags (0–5); Column chart — Default rate: meets credit policy vs exception; Column chart — Default rate by term.

Slicers on every page (synced): Grade, Issue year, Region.

## Data model (star schema, single-direction many-to-one relationships)

| From (many) | To (one) |
|---|---|
| `loans[issue_d]` | `Date[Date]` |
| `loans[addr_state]` | `dim_state[state_code]` |

`Date` is built in Power Query and marked as the date table. All measures live in the `_Measures` table:
[`measures.dax`](measures.dax). All queries: [`power_query.m`](power_query.m).

## Open and refresh

1. Open `Banking_LendingClub.pbix` in Power BI Desktop (free, Windows). The data is already inside the file.
2. To reload from the CSVs: **Home → Transform data → Edit parameters → DataFolder** = the full path of this
   project's `data\cleaned\` folder (ending with `\`), then **Refresh**.

## Numbers to expect (no slicer selected)

| Measure | Value |
|---|---|
| Loans | 42,535 |
| Funded Amount | $460.3M |
| Average Loan | $11,090 |
| Average Interest Rate | 12.17% |
| Default Rate % | 15.7% |
| Net Return % | 8.5% |
| Principal Lost | $44.3M |

These match the notebook (`reports/kpi_summary.json`), SQL (`sql/results/`) and the Excel workbook.
