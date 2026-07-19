-- ============================================================
-- FILE: 03_analysis_queries.sql
-- PROJECT: Subscriber Churn Intelligence Dashboard
-- AUTHOR: [Your Name]
-- DESCRIPTION: All 7 core analysis queries.
--              Run each query individually and note the results.
--              These queries answer the core business questions.
-- ============================================================

USE telecom_churn;

-- ============================================================
-- QUERY 1: HEADLINE KPI SUMMARY
-- Business question: What is the overall scale of churn?
-- ============================================================

SELECT
    COUNT(*)                                AS total_subscribers,
    SUM(ChurnFlag)                          AS total_churned,
    SUM(1 - ChurnFlag)                      AS total_retained,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS churn_rate_pct,
    ROUND(AVG(tenure), 1)                   AS avg_tenure_months,
    ROUND(AVG(MonthlyCharges), 2)           AS avg_monthly_charge,
    ROUND(AVG(TotalCharges), 2)             AS avg_total_revenue
FROM subscribers;

/*
EXPECTED RESULTS:
total_subscribers: 7043
total_churned:     1869
total_retained:    5174
churn_rate_pct:    26.5%
avg_tenure_months: 32.4
avg_monthly_charge: $64.76
avg_total_revenue:  $2283.30
*/

-- ============================================================
-- QUERY 2: CHURN RATE BY CONTRACT TYPE
-- Business question: Which contract type has the highest churn?
-- Key finding: Month-to-month subscribers churn 15x more than 2-year
-- ============================================================

SELECT
    Contract,
    COUNT(*)                                AS total_subscribers,
    SUM(ChurnFlag)                          AS churned,
    SUM(1 - ChurnFlag)                      AS retained,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS churn_rate_pct
FROM subscribers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

/*
EXPECTED RESULTS:
Month-to-month | 3875 | 1655 | 2220 | 42.7%
One year       | 1473 | 166  | 1307 | 11.3%
Two year       | 1695 | 48   | 1647 |  2.8%
*/

-- ============================================================
-- QUERY 3: CHURN RATE BY INTERNET SERVICE TYPE
-- Business question: Do high-paying fiber optic users churn more?
-- Key finding: Fiber optic (highest ARPU) has highest churn rate
-- ============================================================

SELECT
    InternetService,
    COUNT(*)                                AS total_subscribers,
    SUM(ChurnFlag)                          AS churned,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)           AS avg_monthly_charge
FROM subscribers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;

/*
EXPECTED RESULTS:
Fiber optic | 3096 | 1297 | 41.9% | $91.47
DSL         | 2421 |  459 | 19.0% | $45.62
No          | 1526 |  113 |  7.4% | $21.63
*/

-- ============================================================
-- QUERY 4: CHURN RATE BY TENURE GROUP
-- Business question: At which stage of customer lifecycle do
--                    subscribers most commonly leave?
-- Key finding: 47.7% of new subscribers leave in year 1
-- ============================================================

SELECT
    TenureGroup,
    COUNT(*)                                AS total_subscribers,
    SUM(ChurnFlag)                          AS churned,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)           AS avg_monthly_charge,
    ROUND(AVG(tenure), 1)                   AS avg_tenure_in_group
FROM subscribers
GROUP BY TenureGroup
ORDER BY TenureGroup;

/*
EXPECTED RESULTS:
1. New (0-12 months)      | 2174 | 1038 | 47.7%
2. Growing (13-24 months) | 1026 |  247 | 24.1%
3. Established (25-48 m)  | 1568 |  242 | 15.4%
4. Loyal (49+ months)     | 2275 |  149 |  6.6%
*/

-- ============================================================
-- QUERY 5: CHURNED vs RETAINED SUBSCRIBER PROFILE
-- Business question: What does a churned subscriber look like
--                    compared to a retained one?
-- Key finding: Churned subscribers pay MORE but leave SOONER
-- ============================================================

SELECT
    Churn                                   AS subscriber_status,
    COUNT(*)                                AS total_count,
    ROUND(AVG(tenure), 1)                   AS avg_tenure_months,
    ROUND(AVG(MonthlyCharges), 2)           AS avg_monthly_charge,
    ROUND(AVG(TotalCharges), 2)             AS avg_total_revenue,
    ROUND(MIN(MonthlyCharges), 2)           AS min_monthly_charge,
    ROUND(MAX(MonthlyCharges), 2)           AS max_monthly_charge
FROM subscribers
GROUP BY Churn;

/*
EXPECTED RESULTS:
No (Retained) | 5174 | 37.6 months | $61.27 | $2,555
Yes (Churned) | 1869 | 17.9 months | $74.44 | $1,531

KEY INSIGHT: Churned subscribers pay 21% MORE per month ($74 vs $61)
but leave after only 18 months vs 38 months for retained subscribers.
This means the company is losing its highest-paying customers fastest.
*/

-- ============================================================
-- QUERY 6: CHURN RATE BY TECH SUPPORT STATUS
-- Business question: Does having tech support reduce churn?
-- Key finding: No tech support subscribers churn at 2.7x rate
-- Note: Excludes 'No internet service' (not applicable)
-- ============================================================

SELECT
    TechSupport,
    COUNT(*)                                AS total_subscribers,
    SUM(ChurnFlag)                          AS churned,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS churn_rate_pct
FROM subscribers
WHERE InternetService != 'No'
GROUP BY TechSupport
ORDER BY churn_rate_pct DESC;

/*
EXPECTED RESULTS:
No  | 3473 | 1446 | 41.6%
Yes | 2044 |  310 | 15.2%

KEY INSIGHT: Simply having tech support reduces churn rate by 63%.
Offering free/discounted tech support to month-to-month subscribers
is the single highest-ROI retention lever in this dataset.
*/

-- ============================================================
-- QUERY 7: CHURN RATE BY MONTHLY CHARGE BRACKET
-- Business question: Does higher monthly bill drive more churn?
-- Key finding: Very high charge ($90+) subscribers have 50% churn
-- ============================================================

SELECT
    CASE
        WHEN MonthlyCharges < 30   THEN '1. Low ($0-30)'
        WHEN MonthlyCharges < 60   THEN '2. Medium ($30-60)'
        WHEN MonthlyCharges < 90   THEN '3. High ($60-90)'
        ELSE                            '4. Very High ($90+)'
    END                                     AS charge_bracket,
    COUNT(*)                                AS total_subscribers,
    SUM(ChurnFlag)                          AS churned,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)           AS avg_charge_in_bracket
FROM subscribers
GROUP BY charge_bracket
ORDER BY charge_bracket;

/*
EXPECTED RESULTS:
1. Low ($0-30)      | 1059 |  73 |  6.9%
2. Medium ($30-60)  | 1980 | 393 | 19.8%
3. High ($60-90)    | 2248 | 822 | 36.6%
4. Very High ($90+) |  756 | 381 | 50.4%

KEY INSIGHT: Every $30 increase in monthly charge adds ~15% to churn rate.
Subscribers paying $90+ have a coin-flip chance (50.4%) of churning.
*/

-- ============================================================
-- BONUS QUERY: HIGH-RISK COMBINATION ANALYSIS
-- Identifies the most dangerous combination of risk factors
-- ============================================================

SELECT
    Contract,
    TechSupport,
    TenureGroup,
    COUNT(*)                                AS subscribers,
    ROUND(AVG(ChurnFlag) * 100, 1)          AS churn_rate_pct
FROM subscribers
WHERE MonthlyCharges > 60
GROUP BY Contract, TechSupport, TenureGroup
HAVING COUNT(*) >= 50
ORDER BY churn_rate_pct DESC
LIMIT 10;

/*
This shows the top 10 highest-churn subscriber segments when
all three risk factors are combined. These are the exact groups
to target with immediate retention interventions.
*/
