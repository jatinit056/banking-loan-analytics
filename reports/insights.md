# Business insights — Banking Customer & Loan Analytics (LendingClub 2007–2011)

Scope: 42,535 loans ($460.3M funded), 40,347 finished. Numbers come from `reports/kpi_summary.json` (notebook) and `sql/results/` (PostgreSQL).

## 1. Lending doubled in a year

**Insight:** Funded volume grew +104% in 2011; 2011 loans are 51.1% of all 42,535 loans ($460.3M funded in total).

**Business impact:** Fast growth can hide weaker credit quality until loans mature.

**Recommendation:** Track every new vintage's early defaults monthly and compare them with older vintages at the same age.

## 2. One in six finished loans defaulted — but the portfolio still made money

**Insight:** 15.7% of 40,347 finished loans were charged off, losing $44.3M of principal after $4.1M of recoveries (loss-given-default 61.4%). Interest still produced a net return of 8.5%.

**Business impact:** Profitability depends on interest income staying ahead of losses; a small rise in defaults erodes it quickly.

**Recommendation:** Set a portfolio loss limit and monitor default rate and net return together.

## 3. Grades rank risk well, but grades F–G are under-priced

**Insight:** Default rises from 6.0% (A) to 36.2% (G) and rates from 7.3% to 20.5%. On 36-month loans, net return climbs to 9.8% for D, then falls to 0.1% for F and 2.7% for G.

**Business impact:** The riskiest loans earn almost nothing for investors once losses are counted.

**Recommendation:** Raise rates or cap volume for grades F–G; focus growth on B–E.

## 4. 60-month loans are more than twice as risky

**Insight:** 60-month loans default at 27.8% vs 12.3% for 36-month. Inside every grade the long term is worse (grade B: 20.8% vs 11.0%).

**Business impact:** Long terms give borrowers more time to run into trouble.

**Recommendation:** Offer 60-month terms only to grades A–B, or price them higher.

## 5. Small-business loans are the riskiest purpose

**Insight:** Small-business loans default at 29.3%, vs 11.5% for credit-card refinancing and 11.4% for car loans. Debt consolidation is 46.5% of loans and defaults at 16.2%.

**Business impact:** Purpose is a strong, simple signal that the grade does not fully capture.

**Recommendation:** Require extra documentation (business revenue, plan) and lower limits for small-business loans.

## 6. High-income customers are lower-risk and more profitable

**Insight:** Borrowers earning <$30K default at 20.0%; the top 10% by income (≥ $116,736) default at 12.6% vs 16.0% and returned 12.3% vs 7.8%.

**Business impact:** High-income borrowers are the most valuable customer segment.

**Recommendation:** Target marketing and pre-approved offers at high-income, low-DTI customers.

## 7. Credit stress shows up before default

**Insight:** Utilisation above 100% defaults at 37.9% vs 11.0% for 0–25%; 4+ inquiries in 6 months at 27.4% vs 12.5% with none.

**Business impact:** Borrowers who are maxed out or shopping for credit are under financial pressure.

**Recommendation:** Add hard review rules for utilisation > 100% and 4+ recent inquiries.

## 8. A simple 5-flag score separates good and bad loans

**Insight:** Loans with 0 risk flags (42.0% of finished loans) default at 8.7%; loans with 3+ flags (3.6%) default at 34.0% (SQL Q23).

**Business impact:** Easy-to-explain rules can support credit decisions without a complex model.

**Recommendation:** Route loans with 3+ flags to manual review or a higher price.

## 9. Policy exceptions performed much worse

**Insight:** 2,749 loans (6.5%) would not meet the current credit policy; they defaulted at 27.7% vs 14.8%.

**Business impact:** The tightened policy is justified by the data.

**Recommendation:** Keep the current policy and do not grant exceptions without strong compensating factors.

## 10. Verification and missing data are warning signs

**Insight:** Verified-income borrowers defaulted at 17.6% vs 14.5% not verified — verification was used for riskier/larger applications. Borrowers with no employment length defaulted at 23.2% vs 15.5%.

**Business impact:** Missing information and the need to verify both signal higher risk.

**Recommendation:** Treat missing employment data as a reason for manual review.

## 11. Risk differs by region and state

**Insight:** California is the largest market (17.8% of funded volume, default 17.1%). The West has the highest regional default rate (17.0%), the Northeast the lowest (14.3%). Among states with 500+ finished loans, FL (19.6%) and MO (19.1%) are highest; TX is lowest (13.2%). ND had no loans.

**Business impact:** Regional differences affect where growth is safest.

**Recommendation:** Grow in lower-risk large states (TX, NY); tighten pricing in FL and MO.

## 12. Large loans are riskier but priced for it

**Insight:** Loans of $25K+ default at 22.0% vs 15.2%, but carry an average rate of 15.0% vs 11.9% and returned 9.0% vs 8.4%. 97.6% of requested money was funded; 1,997 loans were only partly funded.

**Business impact:** Pricing for loan size works on average, but large losses are concentrated.

**Recommendation:** Keep risk-based pricing for large loans and cap exposure per borrower.

## What the data cannot tell us

* **Approval and rejection rates** — only approved loans are in this file.
* **Credit score, age, gender** — not included in this version of the data.
* **Branch performance** — LendingClub is online-only; state and region are used instead.
