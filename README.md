# 📡 Subscriber Churn Intelligence Dashboard

**Bangladesh Telecom Market Analysis — Grameenphone / Robi Context**

> **Tools:** MySQL · Power BI · DAX  ·  **Dataset:** IBM Telco Customer Churn (7,043 subscribers)  ·  **Type:** End-to-end data analysis portfolio

![Dashboard Preview](Screenshot%202026-07-19%20082402.png)

## Overview

A complete subscriber churn analysis system for the Bangladesh telecom market, covering the full workflow from raw data and SQL analysis to an interactive Power BI dashboard.

> *"Which subscribers are most likely to leave — and what can the company do about it?"*

## Dataset

| Property | Detail |
|----------|--------|
| **Name** | IBM Telco Customer Churn Dataset |
| **Source** | [Kaggle](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) |
| **Rows** | 7,043 subscribers |
| **Columns** | 21 original + 2 engineered (TenureGroup, ChurnFlag) |
| **Target** | `Churn` (Yes / No) |

## Project Structure

```
telecom-churn-dashboard/
├── README.md                       ← You are here
├── Screenshot 2026-07-19 082402.png ← Dashboard screenshot
├── sql/                           ← DB setup, cleaning, queries, views, risk scoring
├── data/churn_data_cleaned.csv    ← Cleaned dataset
├── powerbi/Telecom_Churn_Dashboard.pbix
└── report/Project_Report.md
```

## Key Findings

- **26.5%** overall churn rate — 1 in 4 subscribers leaves annually.
- **Contract type is the #1 driver:** Month-to-month churns at 42.7% vs 2.8% for two-year (15× higher).
- **New subscribers are most vulnerable:** 47.7% churn in the first 12 months.
- **Highest-paying churn most:** Fiber-optic subscribers pay $91.47/mo but churn at 41.9%.
- **Tech support retains:** No support churns at 41.6% vs 15.2% with support (2.7×).
- **Churned pay more, stay less:** $74.44/mo for 17.9 months vs $61.27/mo for 37.6 months.

## Recommendations

1. **"First Year Shield"** — proactive outreach at months 3/6/9 for new month-to-month subscribers.
2. **Expand tech support** — offer free support to at-risk subscribers (highest-ROI lever).
3. **6-month contract option** — bridge gap between monthly and annual churn rates.

## SQL & Power BI

- **8 queries** covering churn by contract, internet service, tenure, tech support, charges, and a risk-score model.
- **4 views** for Power BI: `vw_churn_summary`, `vw_churn_by_contract`, `vw_churn_by_tenure`, `vw_subscriber_risk`.
- **Dashboard:** 2 pages (Churn Overview, Risk Analysis) with KPI cards, donut/bar/line charts, heatmap, and slicers.
- **DAX:** Total Subscribers, Total Churned, Churn Rate %, Avg Monthly Charge, Avg Tenure.

## Business Impact

At Grameenphone scale (76M subscribers, ARPU Tk 185/mo): ~Tk 29,415 crore annual revenue at risk. A 5% retention improvement saves **Tk 1,470 crore/year**.

## How to Reproduce

1. **Setup DB** (MySQL 8.0+):
   ```sql
   source sql/01_database_setup.sql
   source sql/02_data_cleaning.sql
   source sql/03_analysis_queries.sql
   source sql/04_create_views.sql
   ```
2. **Import data** via `LOAD DATA LOCAL INFILE` into `subscribers` table.
3. **Power BI:** Open `.pbix`, update MySQL connection (`localhost` / `telecom_churn`), refresh.

## Skills Demonstrated

MySQL · SQL · Data cleaning & feature engineering · Churn & risk analysis · Power BI & DAX · Executive reporting & ROI modelling

## Author

**[Your Name]** — Aspiring Data Analyst, Bangladesh  ·  📧 your.email@gmail.com  ·  🔗 [LinkedIn](#) | [Portfolio](#)

*Educational/portfolio project using the public IBM Telco dataset. Business figures are illustrative estimates.*
