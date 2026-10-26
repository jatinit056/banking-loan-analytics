# SQL business questions

Queries run on PostgreSQL 16 against `schema.sql`, loaded with `load_data.sql` from the cleaned CSV. Outputs: `results/Q01.csv` … `results/Q23.csv`; preview: `results/summary.md`.

| # | Business question | SQL concepts | Key result (actual run) |
|---|---|---|---|
| Q01 | What does the loan portfolio look like overall? | Aggregates, PERCENTILE_CONT, CASE in AVG | 42,535 loans · $460.3M funded · funding rate 97.58% · median income $59,000 |
| Q02 | How are loans and money split across grades? | GROUP BY, window SUM() OVER () | Grade B largest (29.1% of loans) |
| Q03 | What is the status of the portfolio? | GROUP BY two columns | 2,188 active loans, $6.1M outstanding |
| Q04 | What are customers borrowing for? | GROUP BY, ORDER BY, LIMIT | Debt consolidation 19,776 loans |
| Q05 | How fast did lending grow each year? | EXTRACT, MIN/MAX dates | 2011: 21,721 loans |
| Q06 | Who are the borrowers by income band? | CASE WHEN, FILTER | Under $30K: 19.99% default |
| Q07 | What is the default rate and net return by grade? | WHERE, FILTER, ratios | A 6.03% → G 36.19% default |
| Q08 | How does term change default inside each grade? | Pivot with FILTER, NULLIF | Grade C: 36m 15.52% vs 60m 26.22% |
| Q09 | Which states (500+ finished loans) default most? | INNER JOIN, HAVING | Highest: FL 19.55%; lowest: TX 13.15% |
| Q10 | Which states have (almost) no loans? | LEFT JOIN, COUNT(col), HAVING | No loans: ND; fewest: ME, ID, NE |
| Q11 | How does each US region perform? | JOIN, window share, PERCENTILE_CONT | South 32.8% of funded; West highest default 16.96% |
| Q12 | Which purposes are riskier than average? | Subquery in HAVING | 8 purposes above average; worst Small business 29.32% |
| Q13 | Do top-10% income customers behave differently? | CTE, PERCENTILE_CONT, CROSS JOIN | Top 10%: 12.56% default, 12.27% return |
| Q14 | How did policy exceptions perform? | CASE, FILTER, window share | Exceptions 27.72% vs 14.80% |
| Q15 | What is the cumulative funded amount by month? | Running total window | 55 months; cumulative $460.3M |
| Q16 | Quarter-over-quarter funding growth? | CTE + LAG | 2011 quarters grew 23.2% per quarter on average (2011Q4: +26.7%) |
| Q17 | Which sub-grade is riskiest in each grade? | RANK, DENSE_RANK, PARTITION BY | Riskiest sub-grade overall: F5 (50.74%) |
| Q18 | Top 3 riskiest purposes per region? | DENSE_RANK in a subquery | Small business is #1 in 4 of 4 regions |
| Q19 | Top 3 states by funded amount per region? | ROW_NUMBER | Midwest: IL; Northeast: NY; South: TX; West: CA |
| Q20 | Default rate across income deciles? | NTILE(10) | Decile 1 19.85% → decile 9 11.63% |
| Q21 | How did default change by vintage? | LAG on a CTE | 2007 26.20% → 2009 13.69% |
| Q22 | How much principal was lost and recovered by grade? | Loss analysis, cumulative share window | Net loss $44.3M; LGD A 51.1% → G 68.3% |
| Q23 | Do simple risk flags separate good and bad loans? | CASE-based score | 0 flags 8.70% vs 3 flags 33.85% |

## How to run

```bash
createdb lending_db
psql -d lending_db -f sql/schema.sql
psql -d lending_db -f sql/load_data.sql      # from the project root, after running the notebook
psql -d lending_db -f sql/analysis_queries.sql
python scripts/run_sql_queries.py --db lending_db
```
