# SQL vs Python reconciliation

Each KPI was calculated independently in PostgreSQL (`sql/analysis_queries.sql`) and in pandas (notebook). A check passes when both agree (money within $0.05, percentages within 0.01 points).

| Check | SQL | Python | Result |
|---|---|---|---|
| Loans (Q01) | 42535.0 | 42535.0 | PASS |
| Requested amount $ (Q01) | 471701350.0 | 471701350.0 | PASS |
| Funded amount $ (Q01) | 460296150.0 | 460296150.0 | PASS |
| Funding rate % (Q01) | 97.58 | 97.58 | PASS |
| Average loan $ (Q01) | 11089.72 | 11089.72 | PASS |
| Average interest rate % (Q01) | 12.17 | 12.17 | PASS |
| 60-month share % (Q01) | 25.86 | 25.86 | PASS |
| Median income $ (Q01) | 59000.0 | 59000.0 | PASS |
| Default rate grade A % (Q07) | 6.03 | 6.03 | PASS |
| Default rate grade B % (Q07) | 12.75 | 12.75 | PASS |
| Default rate grade C % (Q07) | 17.97 | 17.97 | PASS |
| Default rate grade D % (Q07) | 23.21 | 23.21 | PASS |
| Default rate grade E % (Q07) | 28.31 | 28.31 | PASS |
| Default rate grade F % (Q07) | 35.72 | 35.72 | PASS |
| Default rate grade G % (Q07) | 36.19 | 36.19 | PASS |
| Net return grade A % (Q07) | 7.15 | 7.15 | PASS |
| Net return grade B % (Q07) | 8.75 | 8.75 | PASS |
| Net return grade C % (Q07) | 8.88 | 8.88 | PASS |
| Net return grade D % (Q07) | 8.87 | 8.87 | PASS |
| Net return grade E % (Q07) | 9.91 | 9.91 | PASS |
| Net return grade F % (Q07) | 6.21 | 6.21 | PASS |
| Net return grade G % (Q07) | 8.86 | 8.86 | PASS |
| Charged-off loans (Q07 total) | 6327 | 6327.0 | PASS |
| Resolved loans (Q07 total) | 40347 | 40347.0 | PASS |
| Default rate A 36m % (Q08) | 5.88 | 5.88 | PASS |
| Default rate A 60m % (Q08) | 10.0 | 10.0 | PASS |
| Default rate B 36m % (Q08) | 11.01 | 11.01 | PASS |
| Default rate B 60m % (Q08) | 20.79 | 20.79 | PASS |
| Default rate C 36m % (Q08) | 15.52 | 15.52 | PASS |
| Default rate C 60m % (Q08) | 26.22 | 26.22 | PASS |
| Default rate D 36m % (Q08) | 19.49 | 19.49 | PASS |
| Default rate D 60m % (Q08) | 31.49 | 31.49 | PASS |
| Default rate E 36m % (Q08) | 22.67 | 22.67 | PASS |
| Default rate E 60m % (Q08) | 32.53 | 32.53 | PASS |
| Default rate F 36m % (Q08) | 31.72 | 31.72 | PASS |
| Default rate F 60m % (Q08) | 37.98 | 37.98 | PASS |
| Default rate G 36m % (Q08) | 35.91 | 35.91 | PASS |
| Default rate G 60m % (Q08) | 36.43 | 36.43 | PASS |
| Default rate South % (Q11) | 15.69 | 15.69 | PASS |
| Funded share South % (Q11) | 32.81 | 32.81 | PASS |
| Default rate West % (Q11) | 16.96 | 16.96 | PASS |
| Funded share West % (Q11) | 28.46 | 28.46 | PASS |
| Default rate Northeast % (Q11) | 14.35 | 14.35 | PASS |
| Funded share Northeast % (Q11) | 24.58 | 24.58 | PASS |
| Default rate Midwest % (Q11) | 15.4 | 15.4 | PASS |
| Funded share Midwest % (Q11) | 14.15 | 14.15 | PASS |
| Top-10% income threshold $ (Q13) | 116736.0 | 116736.0 | PASS |
| Default rate top-10% income % (Q13) | 12.56 | 12.56 | PASS |
| Default rate 'Does not meet policy' % (Q14) | 27.72 | 27.72 | PASS |
| Default rate 'Meets current policy' % (Q14) | 14.8 | 14.8 | PASS |
| Default rate vintage 2007 % (Q21) | 26.2 | 26.2 | PASS |
| Default rate vintage 2008 % (Q21) | 20.73 | 20.73 | PASS |
| Default rate vintage 2009 % (Q21) | 13.69 | 13.69 | PASS |
| Default rate vintage 2010 % (Q21) | 14.05 | 14.05 | PASS |
| Default rate vintage 2011 % (Q21) | 16.32 | 16.32 | PASS |
| Net principal lost $ (Q22 total) | 44293848.577037 | 44293848.577 | PASS |
| Recoveries $ (Q22 total) | 4137589.972963 | 4137589.973 | PASS |
| Worst state (FL) default rate % (Q09) | 19.55 | 19.55 | PASS |
| Worst state code (Q09) | FL | FL | PASS |
| States with no loans (Q10) | ND | ND | PASS |

**60 of 60 checks passed.**
