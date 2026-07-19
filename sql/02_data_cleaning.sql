-- ============================================================
-- FILE: 02_data_cleaning.sql
-- PROJECT: Subscriber Churn Intelligence Dashboard
-- AUTHOR: [Your Name]
-- DESCRIPTION: Data cleaning and feature engineering
--              Adds TenureGroup and ChurnFlag columns
-- ============================================================

USE telecom_churn;

-- ============================================================
-- SECTION 1: DATA QUALITY CHECKS
-- ============================================================

-- Check 1: Total row count (must be 7043)
SELECT COUNT(*) AS total_rows FROM subscribers;

-- Check 2: Count NULL values in key columns
SELECT
    SUM(CASE WHEN tenure IS NULL          THEN 1 ELSE 0 END) AS missing_tenure,
    SUM(CASE WHEN MonthlyCharges IS NULL  THEN 1 ELSE 0 END) AS missing_monthly,
    SUM(CASE WHEN TotalCharges IS NULL    THEN 1 ELSE 0 END) AS missing_total_charges,
    SUM(CASE WHEN Churn IS NULL           THEN 1 ELSE 0 END) AS missing_churn,
    SUM(CASE WHEN Contract IS NULL        THEN 1 ELSE 0 END) AS missing_contract
FROM subscribers;

-- Check 3: Count blank string values in TotalCharges
-- (The CSV stores blanks as empty strings, not NULLs)
SELECT COUNT(*) AS blank_total_charges
FROM subscribers
WHERE TotalCharges = '' OR TotalCharges IS NULL;
-- Expected: 11 rows (new subscribers with 0 months tenure)

-- Check 4: Confirm these 11 blank rows all have tenure = 0
SELECT customerID, tenure, TotalCharges
FROM subscribers
WHERE TotalCharges = '' OR TotalCharges IS NULL;

-- Check 5: Verify distinct values in key categorical columns
SELECT DISTINCT Contract       FROM subscribers ORDER BY Contract;
SELECT DISTINCT InternetService FROM subscribers ORDER BY InternetService;
SELECT DISTINCT TechSupport    FROM subscribers ORDER BY TechSupport;
SELECT DISTINCT Churn          FROM subscribers ORDER BY Churn;

-- ============================================================
-- SECTION 2: DATA CLEANING
-- ============================================================

-- Fix: Replace blank TotalCharges with 0
-- These are new subscribers (tenure=0) who have not been billed yet
UPDATE subscribers
SET TotalCharges = 0
WHERE TotalCharges = '' OR TotalCharges IS NULL;

-- Verify fix worked — should return 0
SELECT COUNT(*) AS remaining_blanks
FROM subscribers
WHERE TotalCharges = '' OR TotalCharges IS NULL;

-- ============================================================
-- SECTION 3: FEATURE ENGINEERING — Add TenureGroup column
-- ============================================================
-- Groups subscribers into lifecycle stages based on how long
-- they have been a customer. Numbers prefix (1., 2., 3., 4.)
-- ensure correct sort order in Power BI.

-- Step 1: Add the new column
ALTER TABLE subscribers ADD COLUMN TenureGroup VARCHAR(30);

-- Step 2: Populate the column using CASE WHEN logic
UPDATE subscribers
SET TenureGroup = CASE
    WHEN tenure <= 12 THEN '1. New (0-12 months)'
    WHEN tenure <= 24 THEN '2. Growing (13-24 months)'
    WHEN tenure <= 48 THEN '3. Established (25-48 months)'
    ELSE                   '4. Loyal (49+ months)'
END;

-- Step 3: Verify distribution
SELECT
    TenureGroup,
    COUNT(*) AS subscriber_count
FROM subscribers
GROUP BY TenureGroup
ORDER BY TenureGroup;

-- ============================================================
-- SECTION 4: FEATURE ENGINEERING — Add ChurnFlag column
-- ============================================================
-- Converts Yes/No text to 1/0 integer.
-- Makes churn rate calculations much simpler:
-- AVG(ChurnFlag) = churn rate as a decimal
-- SUM(ChurnFlag) = count of churned subscribers

-- Step 1: Add the new column
ALTER TABLE subscribers ADD COLUMN ChurnFlag INT;

-- Step 2: Populate — Yes becomes 1, No becomes 0
UPDATE subscribers
SET ChurnFlag = CASE
    WHEN Churn = 'Yes' THEN 1
    ELSE 0
END;

-- Step 3: Verify both values are correct
SELECT
    Churn,
    ChurnFlag,
    COUNT(*) AS subscriber_count
FROM subscribers
GROUP BY Churn, ChurnFlag;
-- Expected:
-- No  | 0 | 5174
-- Yes | 1 | 1869

-- ============================================================
-- SECTION 5: FINAL VERIFICATION
-- ============================================================

-- Confirm final table structure
DESCRIBE subscribers;

-- Confirm row count is still 7043
SELECT COUNT(*) AS final_row_count FROM subscribers;

-- Preview final cleaned data
SELECT
    customerID,
    tenure,
    TenureGroup,
    Contract,
    InternetService,
    TechSupport,
    MonthlyCharges,
    TotalCharges,
    Churn,
    ChurnFlag
FROM subscribers
LIMIT 10;
