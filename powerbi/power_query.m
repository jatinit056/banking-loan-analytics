// =====================================================================
// Power Query (M) of powerbi/Banking_LendingClub.pbix — one block per query.
// DataFolder is a text parameter: the folder that holds the cleaned CSVs (must end with \).
// =====================================================================

// ---------- Parameter: DataFolder ----------
"<path to this project>\data\cleaned\" meta [IsParameterQuery = true, Type = "Text", IsParameterQueryRequired = true]

// ---------- Query: loans ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "loans_clean.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"id", Int64.Type}, {"member_id", Int64.Type}, {"issue_d", type date}, {"issue_year", Int64.Type}, {"issue_quarter", type text}, {"issue_month", type text}, {"loan_amnt", type number}, {"funded_amnt", type number}, {"funded_amnt_inv", type number}, {"funding_gap", type number}, {"term_months", Int64.Type}, {"int_rate", type number}, {"installment", type number}, {"grade", type text}, {"sub_grade", type text}, {"purpose", type text}, {"title", type text}, {"emp_title", type text}, {"emp_length", type text}, {"emp_length_years", Int64.Type}, {"home_ownership", type text}, {"annual_inc", type number}, {"income_band", type text}, {"is_high_income", type logical}, {"verification_status", type text}, {"addr_state", type text}, {"region", type text}, {"zip_code", type text}, {"dti", type number}, {"dti_band", type text}, {"delinq_2yrs", Int64.Type}, {"inq_last_6mths", Int64.Type}, {"open_acc", Int64.Type}, {"pub_rec", Int64.Type}, {"revol_bal", type number}, {"revol_util", type number}, {"revol_util_band", type text}, {"total_acc", Int64.Type}, {"earliest_cr_line", type date}, {"credit_history_years", type number}, {"loan_amount_band", type text}, {"installment_to_income", type number}, {"loan_status", type text}, {"meets_credit_policy", type logical}, {"outcome", type text}, {"is_resolved", type logical}, {"is_bad", type logical}, {"total_pymnt", type number}, {"total_rec_prncp", type number}, {"total_rec_int", type number}, {"total_rec_late_fee", type number}, {"recoveries", type number}, {"collection_recovery_fee", type number}, {"out_prncp", type number}, {"last_pymnt_d", type date}, {"last_pymnt_amnt", type number}, {"net_return", type number}, {"net_principal_loss", type number}}, "en-US"),
    Step1 = Table.AddColumn(Typed, "resolved_flag", each if [is_resolved] then 1 else 0, Int64.Type),
    Step2 = Table.AddColumn(Step1, "bad_flag", each if [is_bad] then 1 else 0, Int64.Type),
    Step3 = Table.AddColumn(Step2, "risk_flags", each (if [dti] >= 20 then 1 else 0) + (if [revol_util] <> null and [revol_util] >= 75 then 1 else 0) + (if [inq_last_6mths] <> null and [inq_last_6mths] >= 3 then 1 else 0) + (if [term_months] = 60 then 1 else 0) + (if [purpose] = "Small business" then 1 else 0), Int64.Type),
    Step4 = Table.AddColumn(Step3, "income_band_order", each List.PositionOf({"<30K", "30–50K", "50–75K", "75–100K", "100–150K", "150K+"}, [income_band]) + 1, Int64.Type),
    Step5 = Table.AddColumn(Step4, "dti_band_order", each List.PositionOf({"0–5", "5–10", "10–15", "15–20", "20–25", "25–30"}, [dti_band]) + 1, Int64.Type),
    Step6 = Table.AddColumn(Step5, "term_label", each Text.From([term_months]) & " months", type text),
    Step7 = Table.AddColumn(Step6, "policy_status", each if [meets_credit_policy] then "Meets policy" else "Policy exception", type text)
in
    Step7

// ---------- Query: dim_state ----------
let
    Source = Csv.Document(File.Contents(DataFolder & "dim_state.csv"), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Blanks = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(Blanks, {{"state_code", type text}, {"state_name", type text}, {"region", type text}}, "en-US")
in
    Typed

// ---------- Query: Date ----------
let
    StartDate = #date(2007, 1, 1),
    EndDate = #date(2011, 12, 31),
    Dates = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),
    AsTable = Table.FromList(Dates, Splitter.SplitByNothing(), {"Date"}),
    Typed = Table.TransformColumnTypes(AsTable, {{"Date", type date}}),
    AddYear = Table.AddColumn(Typed, "Year", each Date.Year([Date]), Int64.Type),
    AddMonthNo = Table.AddColumn(AddYear, "Month Number", each Date.Month([Date]), Int64.Type),
    AddMonthStart = Table.AddColumn(AddMonthNo, "Month Start", each Date.StartOfMonth([Date]), type date),
    AddMonth = Table.AddColumn(AddMonthStart, "Month", each Date.ToText([Date], "MMM yyyy", "en-US"), type text),
    AddMonthName = Table.AddColumn(AddMonth, "Month Name", each Date.ToText([Date], "MMM", "en-US"), type text),
    AddWeekdayNo = Table.AddColumn(AddMonthName, "Weekday Number", each Date.DayOfWeek([Date], Day.Monday) + 1, Int64.Type),
    AddWeekday = Table.AddColumn(AddWeekdayNo, "Weekday", each Date.ToText([Date], "ddd", "en-US"), type text)
in
    AddWeekday
