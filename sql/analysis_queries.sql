/* =====================================================================
   Banking Customer & Loan Analytics (LendingClub 2007–2011) - queries
   Database : PostgreSQL 13+ (tested on PostgreSQL 16)
   Requires : schema.sql -> load_data.sql
   Run      : psql -d lending_db -f sql/analysis_queries.sql
   Definitions:
     resolved loan = outcome 'Fully Paid' or 'Charged Off' (finished)
     default rate  = charged-off loans / resolved loans
     net return    = total payments received / funded amount - 1 (resolved loans, whole life)
   The business question for each query is in sql/business_questions.md.
   ===================================================================== */

SET search_path TO lending;

------------------------------------------------------------------------
-- LEVEL 1 - BASICS
------------------------------------------------------------------------

-- Q01: What does the loan portfolio look like overall?
SELECT COUNT(*)                                          AS loans,
       SUM(loan_amnt)                                    AS requested_amount,
       SUM(funded_amnt)                                  AS funded_amount,
       ROUND(100.0 * SUM(funded_amnt) / SUM(loan_amnt), 2) AS funding_rate_pct,
       ROUND(AVG(loan_amnt), 2)                          AS avg_loan_amount,
       ROUND(AVG(int_rate), 2)                           AS avg_int_rate_pct,
       ROUND(100.0 * AVG(CASE WHEN term_months = 60 THEN 1 ELSE 0 END), 2) AS share_60_month_pct,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY annual_inc) AS median_annual_income,
       ROUND(AVG(dti), 2)                                AS avg_dti
FROM loans;

-- Q02: How are loans and money split across credit grades?
SELECT grade,
       COUNT(*)                                       AS loans,
       SUM(funded_amnt)                               AS funded_amount,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_loans,
       ROUND(AVG(int_rate), 2)                        AS avg_int_rate_pct,
       ROUND(AVG(loan_amnt), 2)                       AS avg_loan_amount
FROM loans
GROUP BY grade
ORDER BY grade;

-- Q03: What is the status of the portfolio (finished vs still running)?
SELECT outcome,
       loan_status,
       COUNT(*)                                       AS loans,
       SUM(funded_amnt)                               AS funded_amount,
       SUM(out_prncp)                                 AS outstanding_principal
FROM loans
GROUP BY outcome, loan_status
ORDER BY outcome, loans DESC;

-- Q04: What are customers borrowing for?
SELECT purpose,
       COUNT(*)                         AS loans,
       SUM(funded_amnt)                 AS funded_amount,
       ROUND(AVG(loan_amnt), 2)         AS avg_loan_amount,
       ROUND(AVG(int_rate), 2)          AS avg_int_rate_pct
FROM loans
GROUP BY purpose
ORDER BY loans DESC
LIMIT 10;

-- Q05: How fast did lending grow each year? (date functions)
SELECT EXTRACT(YEAR FROM issue_d)::int        AS issue_year,
       COUNT(*)                               AS loans,
       SUM(funded_amnt)                       AS funded_amount,
       ROUND(AVG(int_rate), 2)                AS avg_int_rate_pct,
       MIN(issue_d)                           AS first_issue_month,
       MAX(issue_d)                           AS last_issue_month
FROM loans
GROUP BY EXTRACT(YEAR FROM issue_d)
ORDER BY issue_year;

-- Q06: Who are the borrowers by income band? (CASE WHEN on the raw income)
SELECT CASE
           WHEN annual_inc IS NULL     THEN '0. Unknown'
           WHEN annual_inc <  30000    THEN '1. Under $30K'
           WHEN annual_inc <  50000    THEN '2. $30K-50K'
           WHEN annual_inc <  75000    THEN '3. $50K-75K'
           WHEN annual_inc < 100000    THEN '4. $75K-100K'
           WHEN annual_inc < 150000    THEN '5. $100K-150K'
           ELSE                             '6. $150K+'
       END                                                   AS income_band,
       COUNT(*)                                              AS loans,
       ROUND(AVG(loan_amnt), 2)                              AS avg_loan_amount,
       ROUND(AVG(dti), 2)                                    AS avg_dti,
       ROUND(100.0 * AVG(CASE WHEN is_bad THEN 1 ELSE 0 END) FILTER (WHERE is_resolved), 2) AS default_rate_pct
FROM loans
GROUP BY 1
ORDER BY 1;

------------------------------------------------------------------------
-- LEVEL 2 - JOINS, HAVING, SUBQUERIES, CTEs
------------------------------------------------------------------------

-- Q07: What is the default rate and net return by grade?
SELECT grade,
       COUNT(*)                                                        AS resolved_loans,
       COUNT(*) FILTER (WHERE is_bad)                                  AS charged_off,
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_bad) / COUNT(*), 2)     AS default_rate_pct,
       ROUND(AVG(int_rate), 2)                                         AS avg_int_rate_pct,
       ROUND(100.0 * (SUM(total_pymnt) / SUM(funded_amnt) - 1), 2)    AS net_return_pct
FROM loans
WHERE is_resolved
GROUP BY grade
ORDER BY grade;

-- Q08: How does the loan term change the default rate inside each grade? (pivot with FILTER)
SELECT grade,
       ROUND(100.0 * COUNT(*) FILTER (WHERE term_months = 36 AND is_bad)
             / NULLIF(COUNT(*) FILTER (WHERE term_months = 36), 0), 2) AS default_rate_36m_pct,
       ROUND(100.0 * COUNT(*) FILTER (WHERE term_months = 60 AND is_bad)
             / NULLIF(COUNT(*) FILTER (WHERE term_months = 60), 0), 2) AS default_rate_60m_pct,
       COUNT(*) FILTER (WHERE term_months = 60)                         AS resolved_60m_loans
FROM loans
WHERE is_resolved
GROUP BY grade
ORDER BY grade;

-- Q09: Which states (500+ loans) have the highest default rates? (INNER JOIN + HAVING)
SELECT s.state_code,
       s.state_name,
       s.region,
       COUNT(*)                                                     AS resolved_loans,
       ROUND(100.0 * AVG(CASE WHEN l.is_bad THEN 1 ELSE 0 END), 2)  AS default_rate_pct,
       ROUND(AVG(l.int_rate), 2)                                    AS avg_int_rate_pct
FROM loans l
INNER JOIN states s ON s.state_code = l.addr_state
WHERE l.is_resolved
GROUP BY s.state_code, s.state_name, s.region
HAVING COUNT(*) >= 500
ORDER BY default_rate_pct DESC;

-- Q10: Are there states where LendingClub issued no loans at all? (LEFT JOIN ... IS NULL)
SELECT s.state_code,
       s.state_name,
       s.region,
       COUNT(l.id) AS loans
FROM states s
LEFT JOIN loans l ON l.addr_state = s.state_code
GROUP BY s.state_code, s.state_name, s.region
HAVING COUNT(l.id) < 50
ORDER BY loans, s.state_code;

-- Q11: How does each US region perform? (JOIN + aggregates)
SELECT s.region,
       COUNT(*)                                                         AS loans,
       SUM(l.funded_amnt)                                               AS funded_amount,
       ROUND(100.0 * SUM(l.funded_amnt) / SUM(SUM(l.funded_amnt)) OVER (), 2) AS pct_of_funded,
       ROUND(100.0 * COUNT(*) FILTER (WHERE l.is_resolved AND l.is_bad)
             / COUNT(*) FILTER (WHERE l.is_resolved), 2)                AS default_rate_pct,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY l.annual_inc)        AS median_income
FROM loans l
JOIN states s ON s.state_code = l.addr_state
GROUP BY s.region
ORDER BY funded_amount DESC;

-- Q12: Which loan purposes are riskier than the portfolio average? (subquery in HAVING)
SELECT purpose,
       COUNT(*)                                                        AS resolved_loans,
       ROUND(100.0 * AVG(CASE WHEN is_bad THEN 1 ELSE 0 END), 2)       AS default_rate_pct
FROM loans
WHERE is_resolved
GROUP BY purpose
HAVING AVG(CASE WHEN is_bad THEN 1 ELSE 0 END) > (
    SELECT AVG(CASE WHEN is_bad THEN 1 ELSE 0 END) FROM loans WHERE is_resolved
)
ORDER BY default_rate_pct DESC;

-- Q13: Do high-income (top 10%) customers behave differently? (CTE + PERCENTILE_CONT)
WITH threshold AS (
    SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY annual_inc) AS p90_income
    FROM loans
),
labelled AS (
    SELECT l.*,
           CASE WHEN l.annual_inc >= t.p90_income THEN 'Top 10% income' ELSE 'Other borrowers' END AS customer_group,
           t.p90_income
    FROM loans l
    CROSS JOIN threshold t
)
SELECT customer_group,
       ROUND(MAX(p90_income)::numeric, 2)                               AS p90_income_threshold,
       COUNT(*)                                                         AS loans,
       ROUND(AVG(loan_amnt), 2)                                         AS avg_loan_amount,
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_resolved AND is_bad)
             / COUNT(*) FILTER (WHERE is_resolved), 2)                  AS default_rate_pct,
       ROUND(100.0 * (SUM(total_pymnt) FILTER (WHERE is_resolved)
             / SUM(funded_amnt) FILTER (WHERE is_resolved) - 1), 2)     AS net_return_pct
FROM labelled
GROUP BY customer_group
ORDER BY customer_group DESC;

-- Q14: How did loans that do NOT meet the current credit policy perform?
SELECT CASE WHEN meets_credit_policy THEN 'Meets current policy' ELSE 'Does not meet policy' END AS policy_group,
       COUNT(*)                                                         AS loans,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)               AS pct_of_loans,
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_resolved AND is_bad)
             / COUNT(*) FILTER (WHERE is_resolved), 2)                  AS default_rate_pct,
       ROUND(AVG(int_rate), 2)                                          AS avg_int_rate_pct
FROM loans
GROUP BY meets_credit_policy
ORDER BY policy_group;

------------------------------------------------------------------------
-- LEVEL 3 - WINDOW FUNCTIONS
------------------------------------------------------------------------

-- Q15: What is the cumulative funded amount month by month? (running total)
WITH monthly AS (
    SELECT issue_d, COUNT(*) AS loans, SUM(funded_amnt) AS funded
    FROM loans
    GROUP BY issue_d
)
SELECT TO_CHAR(issue_d, 'YYYY-MM')                                         AS month,
       loans,
       funded,
       SUM(funded) OVER (ORDER BY issue_d ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_funded
FROM monthly
ORDER BY issue_d;

-- Q16: What is the quarter-over-quarter growth in funded amount? (LAG)
WITH quarterly AS (
    SELECT issue_quarter, SUM(funded_amnt) AS funded
    FROM loans
    GROUP BY issue_quarter
)
SELECT issue_quarter,
       funded,
       LAG(funded) OVER (ORDER BY issue_quarter)                                     AS previous_quarter,
       ROUND(100.0 * (funded / LAG(funded) OVER (ORDER BY issue_quarter) - 1), 2)    AS qoq_growth_pct
FROM quarterly
ORDER BY issue_quarter;

-- Q17: Inside each grade, which sub-grade is riskiest? (RANK and DENSE_RANK)
WITH sub AS (
    SELECT grade, sub_grade,
           COUNT(*)                                                   AS resolved_loans,
           ROUND(100.0 * AVG(CASE WHEN is_bad THEN 1 ELSE 0 END), 2)  AS default_rate_pct
    FROM loans
    WHERE is_resolved
    GROUP BY grade, sub_grade
)
SELECT grade, sub_grade, resolved_loans, default_rate_pct,
       RANK()       OVER (PARTITION BY grade ORDER BY default_rate_pct DESC) AS rank_in_grade,
       DENSE_RANK() OVER (ORDER BY default_rate_pct DESC)                    AS dense_rank_overall
FROM sub
ORDER BY grade, rank_in_grade;

-- Q18: What are the 3 riskiest purposes in each region (min. 100 resolved loans)? (DENSE_RANK + PARTITION BY)
WITH region_purpose AS (
    SELECT region, purpose,
           COUNT(*)                                                   AS resolved_loans,
           ROUND(100.0 * AVG(CASE WHEN is_bad THEN 1 ELSE 0 END), 2)  AS default_rate_pct
    FROM loans
    WHERE is_resolved
    GROUP BY region, purpose
    HAVING COUNT(*) >= 100
)
SELECT region, risk_rank, purpose, resolved_loans, default_rate_pct
FROM (
    SELECT *, DENSE_RANK() OVER (PARTITION BY region ORDER BY default_rate_pct DESC) AS risk_rank
    FROM region_purpose
) ranked
WHERE risk_rank <= 3
ORDER BY region, risk_rank;

-- Q19: What are the top 3 states by funded amount in each region? (ROW_NUMBER)
WITH state_volume AS (
    SELECT region, addr_state, SUM(funded_amnt) AS funded, COUNT(*) AS loans
    FROM loans
    GROUP BY region, addr_state
)
SELECT region, state_rank, addr_state, loans, funded
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY region ORDER BY funded DESC) AS state_rank
    FROM state_volume
) ranked
WHERE state_rank <= 3
ORDER BY region, state_rank;

-- Q20: How does default rate change across income deciles? (NTILE)
WITH deciles AS (
    SELECT is_bad, annual_inc,
           NTILE(10) OVER (ORDER BY annual_inc) AS income_decile    -- 1 = lowest income
    FROM loans
    WHERE is_resolved AND annual_inc IS NOT NULL
)
SELECT income_decile,
       MIN(annual_inc)                                             AS min_income,
       MAX(annual_inc)                                             AS max_income,
       COUNT(*)                                                    AS resolved_loans,
       ROUND(100.0 * AVG(CASE WHEN is_bad THEN 1 ELSE 0 END), 2)   AS default_rate_pct
FROM deciles
GROUP BY income_decile
ORDER BY income_decile;

-- Q21: How did default rates change from one vintage (issue year) to the next? (LAG on a CTE)
WITH vintage AS (
    SELECT issue_year,
           COUNT(*)                                                   AS resolved_loans,
           ROUND(100.0 * AVG(CASE WHEN is_bad THEN 1 ELSE 0 END), 2)  AS default_rate_pct
    FROM loans
    WHERE is_resolved
    GROUP BY issue_year
)
SELECT issue_year, resolved_loans, default_rate_pct,
       default_rate_pct - LAG(default_rate_pct) OVER (ORDER BY issue_year) AS change_vs_previous_year_pts
FROM vintage
ORDER BY issue_year;

-- Q22: How much principal was lost, and how much was recovered, by grade? (loss analysis + running share)
WITH losses AS (
    SELECT grade,
           COUNT(*)                         AS charged_off_loans,
           SUM(funded_amnt)                 AS funded_charged_off,
           SUM(recoveries)                  AS recoveries,
           SUM(net_principal_loss)          AS net_principal_loss
    FROM loans
    WHERE is_bad
    GROUP BY grade
)
SELECT grade, charged_off_loans, funded_charged_off, recoveries, net_principal_loss,
       ROUND(100.0 * net_principal_loss / funded_charged_off, 2)                         AS loss_given_default_pct,
       ROUND(100.0 * SUM(net_principal_loss) OVER (ORDER BY grade) / SUM(net_principal_loss) OVER (), 2) AS cumulative_loss_share_pct
FROM losses
ORDER BY grade;

-- Q23: Do simple risk flags separate good and bad borrowers? (CASE-based risk score)
WITH flags AS (
    SELECT is_bad,
             (CASE WHEN dti >= 20 THEN 1 ELSE 0 END)
           + (CASE WHEN revol_util >= 75 THEN 1 ELSE 0 END)
           + (CASE WHEN inq_last_6mths >= 3 THEN 1 ELSE 0 END)
           + (CASE WHEN term_months = 60 THEN 1 ELSE 0 END)
           + (CASE WHEN purpose = 'Small business' THEN 1 ELSE 0 END) AS risk_flags
    FROM loans
    WHERE is_resolved
)
SELECT risk_flags,
       COUNT(*)                                                    AS resolved_loans,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)          AS pct_of_loans,
       ROUND(100.0 * AVG(CASE WHEN is_bad THEN 1 ELSE 0 END), 2)   AS default_rate_pct
FROM flags
GROUP BY risk_flags
ORDER BY risk_flags;
