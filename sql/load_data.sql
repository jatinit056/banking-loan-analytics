/* =====================================================================
   Load the cleaned CSV files. Run from the PROJECT ROOT:
       psql -d lending_db -f sql/load_data.sql
   (Run the notebook first: it creates the files in data/cleaned from the raw zip.)
   ===================================================================== */

\copy lending.states FROM 'data/cleaned/dim_state.csv'   WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy lending.loans  FROM 'data/cleaned/loans_clean.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

ANALYZE;

-- Checks: 42,535 loans; the sum of requested amounts must equal LendingClub's control total in the raw file
SELECT COUNT(*) AS loans, SUM(loan_amnt) AS requested_amount,
       SUM(loan_amnt) = 471701350 AS matches_file_control_total
FROM lending.loans;
