-- ============================================================
-- FILE: 01_database_setup.sql
-- PROJECT: Subscriber Churn Intelligence Dashboard
-- AUTHOR: [Your Name]
-- DESCRIPTION: Creates the database and subscribers table
-- ============================================================

-- Step 1: Create the database
CREATE DATABASE IF NOT EXISTS telecom_churn;

-- Step 2: Select the database
USE telecom_churn;

-- Step 3: Create the subscribers table
-- Each column matches the IBM Telco CSV headers exactly
CREATE TABLE IF NOT EXISTS subscribers (
    customerID          VARCHAR(20),
    gender              VARCHAR(10),
    SeniorCitizen       INT,
    Partner             VARCHAR(5),
    Dependents          VARCHAR(5),
    tenure              INT,
    PhoneService        VARCHAR(5),
    MultipleLines       VARCHAR(30),
    InternetService     VARCHAR(30),
    OnlineSecurity      VARCHAR(30),
    OnlineBackup        VARCHAR(30),
    DeviceProtection    VARCHAR(30),
    TechSupport         VARCHAR(30),
    StreamingTV         VARCHAR(30),
    StreamingMovies     VARCHAR(30),
    Contract            VARCHAR(30),
    PaperlessBilling    VARCHAR(5),
    PaymentMethod       VARCHAR(50),
    MonthlyCharges      DECIMAL(10,2),
    TotalCharges        DECIMAL(10,2),
    Churn               VARCHAR(5)
);

-- Step 4: Verify table was created
DESCRIBE subscribers;

-- Step 5: Import data from CSV
-- IMPORTANT: Update the file path to match your CSV file location
-- Use forward slashes even on Windows (e.g. 'C:/Users/YourName/Desktop/churn_data.csv')
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/path/to/your/churn_data.csv'
INTO TABLE subscribers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Step 6: Verify import
SELECT COUNT(*) AS total_rows FROM subscribers;
-- Expected result: 7043

SELECT * FROM subscribers LIMIT 5;
