-- ============================================================
-- FILE: 04_create_views.sql
-- PROJECT: Subscriber Churn Intelligence Dashboard
-- AUTHOR: [Your Name]
-- DESCRIPTION: Creates 4 SQL Views that Power BI connects to.
--              Views act as saved queries — Power BI reads them
--              like tables but they always show current data.
-- ============================================================

USE telecom_churn;

-- Drop existing views if re-running this script
DROP VIEW IF EXISTS vw_churn_summary;
DROP VIEW IF EXISTS vw_churn_by_contract;
DROP VIEW IF EXISTS vw_churn_by_tenure;
DROP VIEW IF EXISTS vw_subscriber_risk;

-- ============================================================
-- VIEW 1: vw_churn_summary
-- Purpose: Headline KPI metrics for the top cards in Power BI
-- Usage: Power BI KPI card visuals
-- ============================================================

CREATE VIEW vw_churn_summary AS
SELECT
    COUNT(*)                                AS total_subscribers,
    SUM(ChurnFlag)                          AS total_churned,
    SUM(1 - ChurnFlag)                      AS total_retained,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS churn_rate_pct,
    ROUND(AVG(tenure), 1)                   AS avg_tenure_months,
    ROUND(AVG(MonthlyCharges), 2)           AS avg_monthly_charge
FROM subscribers;

-- Test View 1
SELECT * FROM vw_churn_summary;

-- ============================================================
-- VIEW 2: vw_churn_by_contract
-- Purpose: Churn rate breakdown by contract type
-- Usage: Power BI bar chart — Churn Rate by Contract Type
-- ============================================================

CREATE VIEW vw_churn_by_contract AS
SELECT
    Contract,
    COUNT(*)                                AS total_subscribers,
    SUM(ChurnFlag)                          AS churned,
    SUM(1 - ChurnFlag)                      AS retained,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)           AS avg_monthly_charge
FROM subscribers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- Test View 2
SELECT * FROM vw_churn_by_contract;

-- ============================================================
-- VIEW 3: vw_churn_by_tenure
-- Purpose: Churn rate across subscriber lifecycle stages
-- Usage: Power BI line chart — Churn Rate by Tenure Group
-- ============================================================

CREATE VIEW vw_churn_by_tenure AS
SELECT
    TenureGroup,
    COUNT(*)                                AS total_subscribers,
    SUM(ChurnFlag)                          AS churned,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)           AS avg_monthly_charge,
    ROUND(AVG(tenure), 1)                   AS avg_tenure_months
FROM subscribers
GROUP BY TenureGroup
ORDER BY TenureGroup;

-- Test View 3
SELECT * FROM vw_churn_by_tenure;

-- ============================================================
-- VIEW 4: vw_subscriber_risk  ← MAIN VIEW (most important)
-- Purpose: Full subscriber dataset enriched with risk score
--          and risk tier. This is the PRIMARY table for all
--          Power BI visuals, slicers, and DAX measures.
-- Usage: All Power BI visuals and slicers
-- ============================================================

CREATE VIEW vw_subscriber_risk AS
SELECT
    -- Original subscriber data
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies,
    Contract,
    PaperlessBilling,
    PaymentMethod,
    MonthlyCharges,
    TotalCharges,
    Churn,
    ChurnFlag,
    TenureGroup,

    -- Engineered: Numeric risk score (0 to 100 points)
    -- Higher score = higher churn probability
    -- Points assigned based on analytical findings from queries 2-7
    (
        CASE WHEN Contract        = 'Month-to-month'  THEN 40 ELSE 0 END +
        CASE WHEN TechSupport     = 'No'              THEN 20 ELSE 0 END +
        CASE WHEN InternetService = 'Fiber optic'     THEN 15 ELSE 0 END +
        CASE WHEN tenure          <= 12               THEN 15 ELSE 0 END +
        CASE WHEN MonthlyCharges  > 70                THEN 10 ELSE 0 END
    )                                                   AS risk_score,

    -- Engineered: Risk tier label based on score thresholds
    CASE
        WHEN (
            CASE WHEN Contract    = 'Month-to-month'  THEN 40 ELSE 0 END +
            CASE WHEN TechSupport = 'No'              THEN 20 ELSE 0 END +
            CASE WHEN tenure      <= 12               THEN 15 ELSE 0 END
        ) >= 60 THEN 'High Risk'
        WHEN (
            CASE WHEN Contract    = 'Month-to-month'  THEN 40 ELSE 0 END +
            CASE WHEN TechSupport = 'No'              THEN 20 ELSE 0 END +
            CASE WHEN tenure      <= 12               THEN 15 ELSE 0 END
        ) >= 35 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END                                                 AS risk_tier

FROM subscribers;

-- Test View 4
SELECT COUNT(*) AS total_rows   FROM vw_subscriber_risk;   -- Expected: 7043
SELECT * FROM vw_subscriber_risk LIMIT 5;

-- Distribution check: verify risk tier counts
SELECT
    risk_tier,
    COUNT(*)                                AS subscribers,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS actual_churn_rate_pct
FROM vw_subscriber_risk
GROUP BY risk_tier
ORDER BY actual_churn_rate_pct DESC;

/*
EXPECTED RISK TIER RESULTS:
High Risk   | ~1972 | ~58% actual churn rate  → model is working well
Medium Risk | ~2464 | ~24% actual churn rate
Low Risk    | ~2607 |  ~5% actual churn rate
*/

-- ============================================================
-- FINAL: List all views created
-- ============================================================

SHOW FULL TABLES IN telecom_churn WHERE TABLE_TYPE LIKE 'VIEW';
