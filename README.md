# 🏦 IndoSynth Gramin Bank — End-to-End Data Analytics & BI Project

<div align="center">

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.x-150458?style=for-the-badge&logo=pandas&logoColor=white)
![Plotly](https://img.shields.io/badge/Plotly-Interactive-3F4F75?style=for-the-badge&logo=plotly&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?style=for-the-badge&logo=jupyter&logoColor=white)
![SciPy](https://img.shields.io/badge/SciPy-Stats-8CAAE6?style=for-the-badge&logo=scipy&logoColor=white)
![License](https://img.shields.io/badge/License-Educational-green?style=for-the-badge)

**A full-scale, 3-phase enterprise data analytics pipeline built on ~3 million banking records.**

[📌 Overview](#-project-overview) • [💡 Problem Statement](#-problem-statement--business-context) • [🏗️ Architecture](#️-project-architecture--workflow) • [🗂️ Dataset](#-dataset-overview) • [📂 Structure](#-repository-structure) • [⚙️ Phases](#️-phase-details--methodology) • [📊 KPIs](#-kpi-dashboard--key-metrics) • [💡 Findings](#-key-findings--business-insights) • [👥 Stakeholders](#-stakeholder-overview) • [🚀 Quick Start](#-installation--quick-start) • [🖼️ Dashboards](#️-power-bi-dashboards) • [❓ FAQ](#-faq--troubleshooting)

</div>

---

## 📌 Project Overview

**IndoSynth Gramin Bank (IGB)** is a simulated rural/regional banking institution in India operating a network of **250 branches** across 5 geographic zones (North, South, East, West, Central). This project builds a complete, enterprise-grade, end-to-end data analytics pipeline — spanning raw CSV data ingestion into a normalized relational database, automated Python-based exploratory data analysis and feature engineering, business SQL reporting, and interactive Power BI dashboards consumed by 13 distinct stakeholder groups.

This is not a toy project. Every design decision — from the MySQL 3NF schema to DAX measure naming conventions — mirrors the workflows used in real banking data teams.

### 🎯 Key Business Objectives

| # | Objective | Owner | Tracked By |
|---|-----------|-------|-----------|
| 1 | Analyze **customer demographics** and segment behavior across rural markets | Head of Retail Banking | Customer Demographics Dashboard |
| 2 | Profile **loan portfolio risk** — approval rates, defaults, and NPA prediction signals | Chief Risk Officer | Risk Monitoring Dashboard |
| 3 | Track **repayment behavior** and EMI delinquency patterns with early warning indicators | Collections Team | Payment Behavior Dashboard |
| 4 | Benchmark **branch efficiency** across all 250 branches and 5 zones | Head of Operations | Branch Operations Dashboard |
| 5 | Quantify **UPI vs. Traditional transaction growth** and digital adoption trends by zone | Head of Digital Banking | Transaction Intelligence Dashboard |
| 6 | Build a **self-serve analytics platform** eliminating manual Excel-based reporting | Business Analyst | All Dashboard Pages |

### 📈 At a Glance

| Metric | Value |
| :--- | :--- |
| Total Records | ~2,902,300 (~3 Million) |
| Database Tables | 9 (3 Fact + 6 Dimension) |
| FK Relationships Defined | 18 |
| MySQL SQL Scripts | 14 (12 curriculum + 1 master + 1 ER screenshot) |
| Business Analysis SQL Files | 5 |
| Python EDA Scripts / Notebooks | 4 |
| Interactive Plotly Charts | 42 |
| Statistical Hypothesis Tests | 4 |
| Derived Features Engineered | 20+ |
| Power BI Dashboard Pages | 5 |
| DAX Measures Created | 40+ |
| BA Documents | 5 (SRS, BRD, Executive Summary, KPI Definitions, Stakeholder Analysis) |
| Project Duration | FY 2018–2025 data coverage (7-year analysis) |

---

## 💡 Problem Statement & Business Context

### The Problem

Before this analytics solution, IndoSynth Gramin Bank faced severe operational blind spots:

| Pain Point | Business Impact | Current State |
|------------|-----------------|---------------|
| **Delayed NPA Detection** | Loan defaults identified weeks after they occur | Manual review only after 90+ days overdue |
| **Siloed Branch Reporting** | Branch managers have zero visibility into network-wide trends | Excel files emailed weekly from each branch |
| **No Digital Adoption Tracking** | UPI growth not quantified, no strategy built on data | UPI share estimated qualitatively only |
| **Manual KPI Reporting** | Error-prone, stale reports reaching leadership 5–7 days late | Weekly Excel dashboards compiled by hand |
| **No Segment Profitability View** | Revenue concentration unknown across customer segments | No aggregated view across customer tables |
| **Rejection Root Cause Unknown** | 38% of loan applications rejected with no systematic analysis | Individual rejection decisions not aggregated |

### The Solution

A **3-phase integrated analytics pipeline** replaces manual processes:

```
Manual Excel Reports  →  MySQL Relational DB  →  Python EDA  →  Power BI Dashboard
     (Before)                (Phase 1)           (Phase 2)        (Phase 3)
```

### Business Scale

| Dimension | Scale |
|-----------|-------|
| Branch Network | 250 branches across 5 zones |
| Customer Base | 100,000 account holders |
| Loan Portfolio | 300,000 loan applications |
| Annual Transactions | 1.5 million financial transactions |
| Employee Workforce | ~2,000 bank staff |
| Active Loan Products | 10 distinct loan types |
| Geographic Coverage | 40 regions across India |

---

## 🏗️ Project Architecture & Workflow

The project follows a standard enterprise data pipeline with three sequential, production-representative phases:

```
[ Raw CSV Datasets ] — 9 Tables, ~3M Records
         │
         ▼
┌──────────────────────────────────────────────────────────┐
│  Phase 1: Relational Database (MySQL 8.0)                │
│  • Normalized ER Schema Design (3NF)                     │
│  • DDL & DML Scripts + Foreign Key Constraints           │
│  • Bulk Loading via LOAD DATA LOCAL INFILE               │
│  • Advanced SQL: Joins, Subqueries, CTEs,                │
│    Window Functions, Views, Stored Procedures, Triggers  │
│  • Business KPI Queries & Domain Case Studies            │
└──────────────────┬───────────────────────────────────────┘
                   │  Python reads cleaned CSV exports
                   ▼
┌──────────────────────────────────────────────────────────┐
│  Phase 2: Exploratory Data Analysis & Cleaning (Python)  │
│  • 9-Step Automated Preprocessing & Feature Engineering  │
│  • Domain-Aware Missing Value & Outlier Handling         │
│  • 42 Interactive Plotly Visualizations & Heatmaps       │
│  • 4 Statistical Hypothesis Tests (T-Test, ANOVA, etc.)  │
│  • Business SQL Analysis Reports                         │
└──────────────────┬───────────────────────────────────────┘
                   │  Cleaned CSVs exported to eda/cleaned_data/
                   ▼
┌──────────────────────────────────────────────────────────┐
│  Phase 3: Business Intelligence Dashboards (Power BI)    │
│  • 5-Page Interactive Dashboard (Rose Gold Theme)        │
│  • Star Schema with 40+ DAX Measures                     │
│  • Executive KPI Summary & Portfolio Risk Tracking       │
│  • Cohort Analysis & Branch Efficiency Monitoring        │
│  • Digital Channel Intelligence (UPI vs Traditional)     │
└──────────────────────────────────────────────────────────┘
```

### ER Schema — Fact & Dimension Table Design

The MySQL database uses a **Star Schema** design with **3 Fact Tables** and **6 Dimension Tables**:

**Fact Tables (High-volume, event-level data):**

| Table | Primary Key | Key FK References | ~Row Count |
|-------|-------------|-------------------|:----------:|
| `loan_applications` | `application_id` | `customer_id`, `branch_id`, `loan_type_id`, `employee_id` | 300,000 |
| `loan_payments` | `payment_id` | `application_id` | 900,000 |
| `transactions` | `transaction_id` | `customer_id`, `branch_id` | 1,500,000 |

**Dimension Tables (Reference / lookup data):**

| Table | Primary Key | ~Row Count | Role |
|-------|-------------|:----------:|------|
| `customers` | `customer_id` | 100,000 | Account holder master |
| `credit_history` | `credit_id` | 100,000 | Credit bureau data |
| `branches` | `branch_id` | 250 | Branch & location master |
| `employees` | `employee_id` | 2,000 | Bank staff master |
| `regions` | `region_id` | 40 | Geographic hierarchy |
| `loan_types` | `loan_type_id` | 10 | Loan product catalogue |

> **18 Foreign Key relationships** enforced across all tables to guarantee referential integrity.

---

## 📊 Dataset Overview — The 9 Core Tables

The dataset simulates a full-scale retail banking ecosystem with **9 interconnected, normalized tables** spanning the entire customer lifecycle:

### 📥 Dataset Access & Download

> 🔗 **[Download Complete Dataset & Power BI Files from Google Drive](https://drive.google.com/drive/folders/1QcMacrT0vicMjUEcL77lpXHNml5AfcKc?usp=drive_link)**

*Since raw CSV datasets (~400 MB, ~3M records) and the Power BI `.pbix` workbook exceed GitHub's recommended repository size, they are hosted on Google Drive.*

**What's included in the Drive package:**
- 📁 `data/` — All 9 raw CSV files (`customers.csv`, `transactions.csv`, `loan_applications.csv`, etc.)
- 📊 `PowerBI/IndoSynth Bank.pbix` — Complete 5-page interactive Power BI workbook
- 📑 Project & Dashboard build guides (`project_guide.md`, `powerbi_dashboard_specification.md`)

---

| Table | Records | Grain / Description | Key Attributes |
| :--- | ---: | :--- | :--- |
| `regions` | 40 | 1 row per geographic region | `region_id`, `zone`, `primary_state` |
| `loan_types` | 10 | 1 row per loan product | `loan_type_id`, `base_interest_rate`, `collateral_required` |
| `branches` | 250 | 1 row per branch office | `branch_id`, `region_id`, `branch_type`, `city` |
| `employees` | ~2,000 | 1 row per bank staff member | `employee_id`, `branch_id`, `designation`, `department` |
| `customers` | 100,000 | 1 row per account holder | `customer_id`, `branch_id`, `annual_income`, `customer_segment` |
| `credit_history` | 100,000 | 1 row per credit bureau record | `credit_score`, `credit_rating`, `credit_utilization_pct` |
| `loan_applications` | 300,000 | 1 row per loan application | `application_id`, `customer_id`, `loan_amount_requested`, `status` |
| `loan_payments` | 900,000 | 1 row per EMI installment | `payment_id`, `application_id`, `payment_status`, `days_late` |
| `transactions` | **1,500,000** | 1 row per financial transaction | `transaction_id`, `customer_id`, `amount`, `transaction_mode` |
| **Total** | **~2,902,300** | | |

### Data Relationships

```
regions (40)
  └─── branches (250) ──────────────────────────────────────┐
         └─── employees (2,000)                              │
         └─── customers (100,000)                            │
                └─── credit_history (100,000)                │
                └─── loan_applications (300,000) ──────────┐ │
                       └─── loan_payments (900,000)         │ │
                └─── transactions (1,500,000) ──────────────┘ │
loan_types (10) ──────────────────────────────────────────────┘
```

---

## 📂 Repository Structure

```
IndoSynth-Gramin-Bank/
│
├── 📂 data/                                    # Raw input datasets (CSV)
│   ├── regions.csv                             # 40 rows — region master
│   ├── loan_types.csv                          # 10 rows — loan product catalogue
│   ├── branches.csv                            # 250 rows — branch offices
│   ├── employees.csv                           # ~2,000 rows — bank staff
│   ├── customers.csv                           # 100,000 rows — account holders
│   ├── credit_history.csv                      # 100,000 rows — credit bureau
│   ├── loan_applications.csv                   # 300,000 rows — loan lifecycle
│   ├── loan_payments.csv                       # 900,000 rows — EMI payments
│   └── transactions.csv                        # 1,500,000 rows — financial txns
│
├── 📂 mysql/                                   # Phase 1: Database Layer
│   ├── complete_mysql_script.sql               # Master DDL/DML + Bulk Load
│   ├── 01_Database_Setup.sql                   # Schema creation & FK constraints
│   ├── 02_Data_Cleaning.sql                    # In-DB data cleaning & validation
│   ├── 03_Joins.sql                            # Multi-table join queries
│   ├── 04_GroupBy.sql                          # Aggregation & grouping analysis
│   ├── 05_Subqueries.sql                       # Nested & correlated subqueries
│   ├── 06_CTE.sql                              # Common Table Expressions
│   ├── 07_Window_Functions.sql                 # RANK, ROW_NUMBER, LAG, LEAD
│   ├── 08_Views.sql                            # Reusable analytical views
│   ├── 09_Stored_Procedures.sql                # Parameterized stored procedures
│   ├── 10_Triggers.sql                         # Audit & automation triggers
│   ├── 11_Case_Studies.sql                     # 5 domain-specific case studies
│   ├── 12_KPIs.sql                             # Executive KPI SQL calculations
│   └── Screenshot 2026-07-08 172155.png        # ER Diagram & schema proof
│
├── 📂 eda/                                     # Phase 2: Python EDA Layer
│   ├── eda_preprocessing.py                    # 9-Step preprocessing script
│   ├── eda_preprocessing.ipynb                 # Documented preprocessing notebook
│   ├── eda_plotly.py                           # 42-chart interactive Plotly script
│   ├── eda_plotly.ipynb                        # Full notebook + 4 stat tests
│   ├── 📂 cleaned_data/                        # Output: 9 cleaned & engineered CSVs
│   │   ├── customers_cleaned.csv
│   │   ├── loan_apps_cleaned.csv
│   │   └── ... (9 files total)
│   └── 📂 charts/                              # Output: 42 interactive HTML charts
│       ├── 01_gender_distribution.html
│       ├── 02_age_distribution.html
│       └── ... (42 files total)
│
├── 📂 business_analysis/                       # Business SQL & Documentation
│   ├── 📂 documents/
│   │   ├── SRS.md                              # Software Requirements Specification
│   │   ├── business_requirements.md            # Business requirements & objectives
│   │   ├── executive_summary.md                # Project executive summary
│   │   ├── kpi_definitions.md                  # KPI definitions & formulas
│   │   └── stakeholder_analysis.md             # Stakeholder register, RACI, communication plan
│   └── 📂 sql_analysis/
│       ├── 01_customer_segmentation.sql        # Customer RFM & behavioral segmentation
│       ├── 02_loan_funnel_analysis.sql          # End-to-end loan application funnel
│       ├── 03_risk_profiling.sql               # NPA & credit risk profiling
│       ├── 04_branch_performance.sql           # Branch & employee performance
│       └── 05_digital_transformation.sql       # UPI adoption & digital growth trends
│
├── 📂 PowerBI/                                 # Phase 3: BI Dashboard Layer
│   ├── IndoSynth Bank.pbix                     # Power BI workbook (5 dashboard pages)
│   └── IndoSynth_RoseGold_Theme.json           # Custom Rose Gold color theme
│
├── 📂 DashBoard Snapshots/                     # Power BI screenshot exports
│   ├── Executive Overview.png
│   ├── Customer Demographics.png
│   ├── Loan Performance & Performance Analytics.png
│   ├── Payment Behavior & Risk Monitoring.png
│   └── Transaction & Digital Channel Intelligence.png
│
├── requirements.txt                            # Python dependencies
├── project_guide.md                            # Full project specification & objectives
├── powerbi_dashboard_specification.md          # Power BI build specification
└── .gitignore                                  # Git ignore rules
```

---

## ⚙️ Phase Details & Methodology

### Phase 1 — MySQL Relational Schema (`/mysql`)

#### 🗄️ Schema Design & Data Ingestion
- **3NF Normalized ER Model** with `PRIMARY KEY` and `FOREIGN KEY` constraints across all 9 tables
- Referential integrity ensures every loan application links to a valid customer, loan type, and loan officer
- `LOAD DATA LOCAL INFILE` with optimized buffer configuration ingests all **~2.9M records** efficiently
- Schema enforces strict data types: `INT NOT NULL` for IDs, `DATE` for dates, `DECIMAL(15,2)` for monetary values

> Enable `local_infile` before running the master script:
> ```sql
> SET GLOBAL local_infile = 1;
> SET GLOBAL innodb_buffer_pool_size = 1073741824; -- 1GB buffer for fast load
> ```

#### 📚 SQL Curriculum — 12 Ordered Scripts

The `mysql/` directory contains a comprehensive, ordered SQL curriculum covering all core SQL concepts applied to real banking domain problems:

| Script | Topic | Key SQL Concepts Covered |
| :--- | :--- | :--- |
| `01_Database_Setup.sql` | Schema & Bulk Load | `CREATE TABLE`, `PRIMARY KEY`, `FOREIGN KEY`, `LOAD DATA LOCAL INFILE` |
| `02_Data_Cleaning.sql` | Data Quality | `UPDATE`, `TRIM`, `CAST`, `IS NULL`, type validation, range checks |
| `03_Joins.sql` | Multi-table Joins | `INNER JOIN`, `LEFT JOIN`, `CROSS JOIN`, multi-table chained joins |
| `04_GroupBy.sql` | Aggregations | `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`, `ROLLUP` |
| `05_Subqueries.sql` | Nested Queries | Correlated subqueries, `EXISTS`, `IN`, scalar subqueries |
| `06_CTE.sql` | Common Table Expressions | Non-recursive `WITH`, multi-CTE chains, CTE reuse |
| `07_Window_Functions.sql` | Window Analytics | `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `LAG()`, `LEAD()`, `NTILE()`, `SUM() OVER()` |
| `08_Views.sql` | Reusable Views | `CREATE VIEW`, view chaining, updatable vs non-updatable views |
| `09_Stored_Procedures.sql` | Automation | `CREATE PROCEDURE`, `IN/OUT` parameters, `CURSOR`, `LOOP` |
| `10_Triggers.sql` | Audit Trails | `AFTER INSERT`, `AFTER UPDATE`, audit table logging, `NEW`/`OLD` |
| `11_Case_Studies.sql` | Domain Case Studies | 5 end-to-end banking scenarios combining all SQL techniques |
| `12_KPIs.sql` | Executive KPI Queries | NPA rate, approval rates, UPI share, cohort analysis, officer rankings |

#### 🔍 Business SQL Analyses (`/business_analysis/sql_analysis/`)

Five themed analytical SQL scripts answer real business questions using advanced SQL:

| Script | Business Question Answered | Techniques Used |
| :--- | :--- | :--- |
| `01_customer_segmentation.sql` | Who are our most valuable customers? Which segments have the best LTV? | RFM scoring, percentile ranks, `NTILE()`, segment cohort CTEs |
| `02_loan_funnel_analysis.sql` | Where in the pipeline do we lose the most applications? What are the top rejection reasons? | Multi-stage funnel with CTEs, Pareto analysis, `CASE WHEN` |
| `03_risk_profiling.sql` | Which customers are highest-risk? What predicts NPA? Which zones have the worst default rates? | `RANK()`, risk tier scoring, zone/branch cross-tabulation |
| `04_branch_performance.sql` | Which branches are overperforming vs. underperforming? Who are the top loan officers? | `DENSE_RANK()`, benchmark comparison, `LAG()` for MoM trends |
| `05_digital_transformation.sql` | How fast is UPI adoption growing? Which branches are digitally lagging? | Year-over-year pivot with `CASE WHEN`, adoption rate trends, `LEAD()` for projections |

---

### Phase 2 — Python Preprocessing & EDA (`/eda`)

#### 🔧 9-Step Preprocessing Pipeline (`eda_preprocessing.ipynb`)

| Step | Operation | Details |
| ---: | :--- | :--- |
| 1 | **Multi-Table Ingestion** | Dynamic loading + memory profiling (~400MB raw data) using `pd.read_csv()` with dtype optimization |
| 2 | **Schema Validation** | Datatype inspection and normalization — verify each column's type matches the business definition |
| 3 | **Missing Value Imputation** | Domain-aware: `rejection_reason` → `'N/A'` for non-rejected loans; `loan_amount_approved` → `0` for pending/rejected; `branch_id` → `-1` for online/digital transactions |
| 4 | **Duplicate Removal** | PK-level and full-row deduplication across all 9 tables with before/after row count reporting |
| 5 | **Temporal Conversion** | 11 date columns standardized to `datetime64[ns]` including `application_date`, `disbursement_date`, `transaction_date` |
| 6 | **Categorical Standardization** | Whitespace trimming (`str.strip()`), `Title Case` normalization for all text columns to eliminate case-mismatch grouping errors |
| 7 | **Outlier Detection (IQR)** | Flags extreme values in `annual_income`, `credit_score`, and `loan_amount_requested` using 1.5×IQR rule — **does not delete** records since high-value banking transactions are legitimate |
| 8 | **Feature Engineering (20+ features)** | See detailed table below |
| 9 | **Automated Export** | All 9 cleaned & enriched tables saved to `eda/cleaned_data/` for downstream Power BI and SQL consumption |

#### 🔨 Feature Engineering — 20+ Derived Attributes

| Feature | Source Column(s) | Business Use |
| :--- | :--- | :--- |
| `age_group` | `date_of_birth` | Segment customers into 18–25, 26–35, 36–50, 51+ cohorts |
| `income_bracket` | `annual_income` | Classify as <2L, 2–5L, 5–10L, 10–20L, 20L+ for segment analysis |
| `account_tenure_years` | `account_open_date` | Measure customer loyalty duration |
| `credit_band` | `credit_score` | Poor (<580), Fair (580–669), Good (670–739), Very Good (740–799), Excellent (800+) |
| `high_utilization` | `credit_utilization_pct` | Flag customers using >75% of credit limit as high-risk |
| `is_approved` | `status` | Binary: 1 if status = Approved or Disbursed, 0 otherwise |
| `amount_gap` | `loan_amount_requested`, `loan_amount_approved` | Requested minus Approved — measures how much was cut |
| `loan_to_income_ratio` | `loan_amount_requested`, `annual_income` | Key credit risk metric — EMI affordability signal |
| `is_late` | `payment_status`, `days_late` | Binary: 1 if payment was late (days_late > 0) |
| `is_missed` | `payment_status` | Binary: 1 if payment_status = 'Missed' |
| `days_late_bucket` | `days_late` | Bucket: On-time, 1–15 days, 16–30 days, 30+ days |
| `txn_year` | `transaction_date` | Year extracted for trend analysis |
| `txn_month` | `transaction_date` | Month extracted for seasonality analysis |
| `txn_quarter` | `transaction_date` | Quarter for quarterly trend charts |
| `txn_day_of_week` | `transaction_date` | Day-of-week for behavioral pattern analysis |
| `txn_hour` | `transaction_datetime` | Hour-of-day for peak usage analysis |
| `amount_bucket` | `amount` | Transaction size buckets: Micro (<500), Small (500–5K), Medium (5K–50K), Large (50K+) |
| `is_upi` | `transaction_mode` | Binary flag for UPI vs. traditional transactions |
| `branch_type_encoded` | `branch_type` | Ordinal encoding: Rural=0, Semi-Urban=1, Urban=2 |
| `zone_encoded` | `zone` | Label-encoded zone for correlation analysis |

#### 📊 42 Interactive Plotly Visualizations (`eda_plotly.ipynb`)

<details>
<summary><b>👥 Section 1 — Customer Demographics (Charts 01–06)</b></summary>

| # | Chart Title | Chart Type | Business Insight |
|---|---|---|---|
| 01 | Gender Distribution | Donut | Male/Female split across customer base |
| 02 | Age Distribution | Histogram | Peak borrowing age groups |
| 03 | Customer Segments | Bar | Premium vs. Mass vs. Rural segment mix |
| 04 | Income by Employment Type | Box Plot | Salary range variation across Salaried, Self-Employed, Farmer |
| 05 | Customers by State | Bar | Geographic concentration — top states by account volume |
| 06 | Education Level vs Income | Grouped Bar | Education premium on annual income |

</details>

<details>
<summary><b>💳 Section 2 — Credit Analysis (Charts 07–10)</b></summary>

| # | Chart Title | Chart Type | Business Insight |
|---|---|---|---|
| 07 | Credit Score Distribution | Histogram | Population distribution across 300–850 score range |
| 08 | Credit Ratings Breakdown | Pie | Share of Poor / Fair / Good / Excellent rated customers |
| 09 | 8-Variable Credit Correlation Matrix | Heatmap | Multicollinearity between credit variables |
| 10 | Credit Utilization vs Score | Scatter | Negative correlation between utilization & creditworthiness |

</details>

<details>
<summary><b>📋 Section 3 — Loan Portfolio (Charts 11–16)</b></summary>

| # | Chart Title | Chart Type | Business Insight |
|---|---|---|---|
| 11 | Loan Status Distribution | Donut | Approved / Pending / Rejected / Disbursed share |
| 12 | Requested vs Approved Amount | Scatter | Amount gap analysis — who gets cut and by how much |
| 13 | Approval Rate by Credit Band | Bar | How credit score drives loan decisions |
| 14 | Rejection Reasons Breakdown | Horizontal Bar | Pareto of top rejection causes |
| 15 | Disbursement by Loan Product | Treemap | Which loan products dominate the portfolio |
| 16 | Monthly Loan Application Trend | Line | Seasonality and growth trend in loan applications |

</details>

<details>
<summary><b>⚠️ Section 4 — Payment & Default Behavior (Charts 17–21)</b></summary>

| # | Chart Title | Chart Type | Business Insight |
|---|---|---|---|
| 17 | Payment Status Breakdown | Donut | On-time vs Late vs Missed EMI distribution |
| 18 | Days Late Distribution | Histogram | Distribution of late days — tail risk visibility |
| 19 | Penalty Collections by Loan Type | Bar | Which loan types generate most penalty revenue |
| 20 | Missed Payment Trend Over Time | Line | Growing or shrinking delinquency trend |
| 21 | Outstanding Balance Analysis | Heatmap | Outstanding balance concentration by zone and loan type |

</details>

<details>
<summary><b>💸 Section 5 — Transaction & Digital Channel Intelligence (Charts 22–25)</b></summary>

| # | Chart Title | Chart Type | Business Insight |
|---|---|---|---|
| 22 | Credit vs Debit Transaction Split | Donut | Inflow vs outflow balance across the customer base |
| 23 | Top Spending Categories | Bar | Where customers spend — retail, agriculture, utilities, etc. |
| 24 | UPI vs Traditional Share Over Years | 100% Stacked Bar | **7-year digital transformation story (2018–2025)** |
| 25 | Monthly Transaction Volume Heatmap | Heatmap | Month × Year volume patterns — peak banking months |

</details>

<details>
<summary><b>🔬 Section 6 — Advanced Analytics & Executive KPIs (Charts 26–30)</b></summary>

| # | Chart Title | Chart Type | Business Insight |
|---|---|---|---|
| 26 | Default Rate by Credit Band | Bar | NPA concentration in Poor/Fair credit bands |
| 27 | Zone-wise Disbursement | Sunburst | Hierarchical view: Zone → Region → Branch |
| 28 | Loan Officer Performance | Bubble Chart | Applications processed × Approval Rate × Volume bubble |
| 29 | Customer Cohort Analysis | Density Heatmap | Acquisition cohort retention & repayment behavior |
| 30 | 2×4 Executive KPI Dashboard | Subplot Grid | 8 KPI gauges in one summary page |

</details>

<details>
<summary><b>📦 Section 7 — Extended Domain Analysis (Charts 31–42)</b></summary>

| # | Chart Title | Business Insight |
|---|---|---|
| 31 | KYC & Active Customer Status | Regulatory compliance — what % are KYC verified? |
| 32 | Account Type Distribution | Savings vs Current vs OD account mix |
| 33 | Marital Status vs Loan Approval Rate | Does marital status influence approval decisions? |
| 34 | Branch Type Performance Analysis | Rural vs Semi-Urban vs Urban processing efficiency |
| 35 | Zone-wise Default Rate | Which zones have the highest NPA concentration? |
| 36 | Loan Tenure by Product Type | Typical repayment duration per loan category |
| 37 | Interest Rate Distribution by Loan Category | Rate spread across Gold, Personal, Education, Agri loans |
| 38 | EMI-to-Income Ratio Analysis | Repayment affordability stress analysis |
| 39 | Employee Gender & Department Mix | Workforce diversity across departments |
| 40 | Repeat Borrower Analysis | What % of customers have multiple loan applications? |
| 41 | Outstanding Balance by Customer Segment | Which segments carry the most outstanding debt? |
| 42 | Seasonal Loan Application Patterns | Pre-harvest and festival-season loan demand spikes |

</details>

#### 🧪 4 Statistical Hypothesis Tests (`scipy.stats`)

| # | Test Method | Null Hypothesis (H₀) | Result | Business Implication |
| ---: | :--- | :--- | :--- | :--- |
| 1 | **Welch's T-Test** | Mean income is equal between approved & rejected applicants | **Reject H₀** (p < 0.05) ✅ | Income is a statistically significant predictor of loan approval |
| 2 | **Chi-Square Test of Independence** | Loan approval rates are independent of gender | Tested & Quantified | Determines if gender bias exists in credit decisions |
| 3 | **One-Way ANOVA** | Mean credit scores are equal across all 5 geographic zones | Tested & Quantified | Identifies if certain zones systematically have lower creditworthiness |
| 4 | **Pearson Correlation** | No linear association between credit score & loan amount requested | Quantified (r value) | Measures if higher credit score customers request larger loans |

---

### Phase 3 — Power BI Dashboards (`/PowerBI`)

A 5-page interactive report built with a custom **Rose Gold** theme (`IndoSynth_RoseGold_Theme.json`):

#### Dashboard Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Color Theme** | Rose Gold — Canvas `#FFF5F0`, Sidebar `#B76E79`, Cards `#FFFFFF` |
| **Navigation** | Left sidebar with page-navigation buttons on all 5 pages |
| **Universal Filter** | `dim_Date[YearMonth]` slicer cross-filters all visuals on every page |
| **Conditional Formatting** | KPI cards use 🟢 Green / 🟡 Yellow / 🔴 Red threshold bands |
| **Cross-Filtering** | Clicking any visual segment filters all other visuals on the page |
| **Performance Target** | Full report loads within 8 seconds on standard hardware |
| **DAX Measures** | 40+ measures in a dedicated `_Measures` table |

#### Dashboard Pages

| Page | Dashboard Name | Primary Users | Key Visuals |
| ---: | :--- | :--- | :--- |
| 1 | **Executive Overview** | MD/CEO, CFO | Total portfolio value, approval rate, NPA rate, active customer KPI cards, trend lines |
| 2 | **Customer Demographics** | Retail Banking Head, Compliance | Age/gender/income splits, state-level distribution, KYC status, segment mix |
| 3 | **Loan Performance & Portfolio Analytics** | Credit Head, CFO | Funnel analysis, credit band approval matrix, disbursement treemap, rejection Pareto |
| 4 | **Payment Behavior & Risk Monitoring** | CRO, Collections | EMI delinquency trends, days-late heatmap, risk tier breakdown, missed payment trend |
| 5 | **Transaction & Digital Channel Intelligence** | Digital Banking Head | UPI adoption trend, category spending, monthly volume heatmap, UPI vs traditional |

---

## 📊 KPI Dashboard & Key Metrics

The project tracks **8 executive KPIs** with defined thresholds, owners, and traffic-light statuses. All KPIs are calculated consistently across MySQL SQL, Python, and Power BI DAX.

| KPI | Green 🟢 | Yellow 🟡 | Red 🔴 | Direction | Owner |
|-----|---------|----------|-------|-----------|-------|
| **Active Customer %** | ≥ 85% | 75–84% | < 75% | ↑ Higher Better | Retail Banking |
| **KYC Verified %** | ≥ 90% | 80–89% | < 80% | ↑ Higher Better | Compliance |
| **Loan Approval Rate %** | ≥ 60% | 45–59% | < 45% | ↑ Higher Better | Credit Head |
| **Disbursement Rate %** | ≥ 55% | 40–54% | < 40% | ↑ Higher Better | Loan Operations |
| **Default Rate % (NPA)** | ≤ 5% | 5–10% | > 10% | ↓ Lower Better | Chief Risk Officer |
| **On-Time Payment Rate %** | ≥ 85% | 75–84% | < 75% | ↑ Higher Better | Collections |
| **UPI Adoption Share %** | ≥ 60% | 40–59% | < 40% | ↑ Higher Better | Digital Banking |
| **Transaction Success Rate %** | ≥ 97% | 92–96% | < 92% | ↑ Higher Better | Technology Ops |

> **Threshold Rationale**: All thresholds are benchmarked against RBI guidelines and industry norms for rural/gramin banks in India. See [`kpi_definitions.md`](business_analysis/documents/kpi_definitions.md) for full governance details.

---

## 💡 Key Findings & Business Insights

Based on the 7-year dataset (FY 2018–2025), the EDA and SQL analyses reveal the following headline findings:

### 🔑 5 Headline Findings

| # | Finding | Business Impact |
|---|---------|----------------|
| 1 | **64.2% loan approval rate** — but 31.5% of applications rejected, many due to fixable reasons | ₹150+ Cr in lost disbursements annually from avoidable rejections |
| 2 | **UPI grew from <15% in 2018 to >65% in 2025** — fastest-growing banking channel | ₹200+ Cr shift from cash to digital reduces branch operational cost by est. 12% |
| 3 | **Default rate at 4.8%** — within the 5% threshold but only 0.2pp of margin | 2,400+ customers in the critical risk zone; one macro shock could breach NPA limits |
| 4 | **Rural branches disburse 66% of total portfolio** but process loans 40% slower | Urban branch processing speed benchmark can transfer to rural via officer training |
| 5 | **Top 3 rejection reasons are addressable** — Low Credit Score, Insufficient Income, Document Gaps | Targeted pre-loan counseling could recover 8–12% of rejected applications |

### 📉 Loan Funnel Leakage Analysis

```
Applications   →   Under Review   →   Approved   →   Disbursed
  300,000           186,000           192,600         ~186,000
    100%              62%               64.2%            ~62%
               ↓ 38% drop-off    ↓ Mostly admin    ↓ Process gap
```

> **Critical insight**: The biggest drop-off is at the **Under Review stage** — 38% of applications never even reach the credit review desk. This is a front-end filtering problem, not a credit quality problem.

**Top 3 Rejection Reasons (Pareto — covers ~78% of all rejections):**
1. **Low Credit Score** (< 600) — 34% of rejections
2. **Insufficient Income** — 28% of rejections
3. **Incomplete Documentation** — 16% of rejections

### 📈 Digital Transformation Trajectory

| Year | UPI Share | Traditional Share |
|------|:---------:|:-----------------:|
| 2018 | < 15% | > 70% |
| 2020 | ~25% | ~58% |
| 2022 | ~48% | ~38% |
| 2024 | ~60% | ~25% |
| 2025 | > 65% | < 20% |

> Customers in the **Heavy UPI tier (>80% UPI transactions)** show a **2.1pp lower default rate** — digital engagement is a proxy for financial discipline.

### ⚠️ Risk Concentration Hotspots

| Risk Area | Finding | Action Required |
|-----------|---------|----------------|
| **North Zone** | 22% higher default rate than bank average | Assign risk officers to 3 highest-default branches |
| **Education Loans** | Estimated 8.2% NPA rate — highest of any product | Mandate minimum 600 credit score without collateral |
| **Below-600 Score Customers** | 12% of loan volume but 41% of all missed payments | Tighter credit policy + enhanced monitoring |

### ✅ Strategic Recommendations

| Area | Quick Win (< 30 days) | Medium Term (3–6 months) | Strategic (6–18 months) |
|------|----------------------|--------------------------|------------------------|
| **Risk** | Flag top 100 high-risk borrowers for CRM follow-up | Introduce credit score floors by loan type | AI-based early warning scoring model |
| **Loans** | Deploy pre-screening eligibility checker | Train officers on documentation efficiency | Straight-through processing for low-risk |
| **Digital** | Set UPI branch-level adoption targets | Launch UPI-linked micro-loan product | Full digital loan application journey |
| **Customers** | Call top 500 Premium segment customers | Design segment-specific product bundles | Customer 360° CRM integration |
| **Branches** | Share top-branch best practices internally | Officer retraining program for North Zone | Performance-linked incentive scheme |

---

## 👥 Stakeholder Overview

The analytics solution serves **13 distinct stakeholder groups** across 4 organizational tiers:

| Tier | Stakeholder | Primary Dashboard | Power-Interest |
|------|-------------|------------------|---------------|
| 🔴 Tier 1 — Executive | MD / CEO | Executive Overview (P1) | Manage Closely |
| 🔴 Tier 1 — Executive | CFO / Finance Head | Executive Overview (P1), Loan Performance (P3) | Keep Satisfied |
| 🔴 Tier 1 — Executive | Chief Risk Officer | Payment Behavior & Risk (P4) | Manage Closely |
| 🟡 Tier 2 — Functional | Head of Retail Banking | Customer Demographics (P2) | Keep Informed |
| 🟡 Tier 2 — Functional | Head of Credit | Loan Performance (P3) | Keep Informed |
| 🟡 Tier 2 — Functional | Head of Digital Banking | Transaction & Digital (P5) | Keep Informed |
| 🟡 Tier 2 — Functional | Head of Operations | All Pages | Monitor |
| 🟡 Tier 2 — Functional | Compliance Officer | Customer Demographics (P2) | Keep Satisfied |
| 🟢 Tier 3 — Operational | Zonal Managers (5) | All Pages (zone-filtered) | Keep Informed |
| 🟢 Tier 3 — Operational | Branch Managers (250) | Branch Operations (P6) | Keep Informed |
| 🟢 Tier 3 — Operational | Loan Officers | Loan Performance (P3) | Monitor |
| ⚙️ Tier 4 — Technical | IT / Database Team | All Pages (technical) | Keep Informed |
| ⚙️ Tier 4 — Technical | Business Analyst | All Pages (authoring) | Manage Closely |

> See [`stakeholder_analysis.md`](business_analysis/documents/stakeholder_analysis.md) for the full RACI matrix, Power-Interest grid, communication plan, and engagement strategies.

---

## 📄 Business Analysis Documents

The `business_analysis/documents/` directory contains 5 professional BA deliverables:

| Document | Purpose | Audience | Key Sections |
|----------|---------|----------|-------------|
| [`SRS.md`](business_analysis/documents/SRS.md) | Software Requirements Specification | Developers, QA, Stakeholders | Functional requirements (FR-01 to FR-26), NFRs, architecture, data model |
| [`business_requirements.md`](business_analysis/documents/business_requirements.md) | Business Requirements Document (BRD) | Business Sponsors, BA Team | Scope, objectives, success metrics, functional requirements |
| [`executive_summary.md`](business_analysis/documents/executive_summary.md) | Data Analytics Findings Report | MD, CFO, CRO, Zonal Heads | 5 headline findings, loan funnel, risk profile, digital transformation, recommendations |
| [`kpi_definitions.md`](business_analysis/documents/kpi_definitions.md) | KPI Governance Dictionary | Power BI Developers, SQL Analysts | DAX formula, SQL formula, thresholds, rationale, owner for all 8 KPIs |
| [`stakeholder_analysis.md`](business_analysis/documents/stakeholder_analysis.md) | Stakeholder Analysis | Project Manager, BA Team | 13 stakeholder profiles, RACI matrix, Power-Interest grid, communication plan, risk register |

---

## 🖼️ Power BI Dashboards

| Executive Overview | Customer Demographics |
|---|---|
| ![Executive Overview](DashBoard%20Snapshots/Executive%20Overview.png) | ![Customer Demographics](DashBoard%20Snapshots/Customer%20Demographics.png) |

| Loan Performance & Portfolio Analytics | Payment Behavior & Risk Monitoring |
|---|---|
| ![Loan Performance](DashBoard%20Snapshots/Loan%20Performance%20%26%20Performance%20Analytics.png) | ![Payment Behavior](DashBoard%20Snapshots/Payment%20Behavior%20%26%20Risk%20Monitoring.png) |

<div align="center">

| Transaction & Digital Channel Intelligence |
|---|
| ![Digital Intelligence](DashBoard%20Snapshots/Transaction%20%26%20Digital%20Channel%20Intelligence.png) |

</div>

---

## 🚀 Installation & Quick Start

### Prerequisites

| Tool | Version | Purpose |
| :--- | :--- | :--- |
| Python | 3.10+ | EDA, preprocessing, visualizations |
| MySQL Server + Workbench | 8.0+ | Relational database layer |
| Power BI Desktop | Latest (March 2025+) | Interactive dashboards |
| Jupyter Notebook / VS Code | Any recent version | Interactive notebooks |
| Git | Any | Cloning the repository |

### Step 1 — Clone & Setup Python Environment

```powershell
# Clone the repository
git clone https://github.com/<your-username>/IndoSynth-Gramin-Bank.git
cd IndoSynth-Gramin-Bank

# Create and activate virtual environment (Windows)
python -m venv venv
.\venv\Scripts\Activate.ps1

# Install all Python dependencies
pip install -r requirements.txt
```

**Dependencies installed (`requirements.txt`):**
```
pandas        # Data manipulation & cleaning
numpy         # Numerical operations
plotly        # Interactive visualizations (42 charts)
scipy         # Statistical hypothesis tests
kaleido       # Static chart export (PNG/SVG)
ipykernel     # Jupyter kernel support
nbformat>=4.2.0  # Notebook format compatibility
```

### Step 2 — Database Setup (Phase 1)

1. Open **MySQL Workbench** and connect to your local MySQL 8.0 server.
2. Run the following to enable bulk loading:
   ```sql
   SET GLOBAL local_infile = 1;
   ```
3. Open `mysql/complete_mysql_script.sql`.
4. **Update** every `LOAD DATA LOCAL INFILE` path to match your local repository path:
   ```sql
   -- Change this:
   LOAD DATA LOCAL INFILE 'B:/Major Project/data/customers.csv'
   -- To this (use your actual path with forward slashes):
   LOAD DATA LOCAL INFILE 'C:/your/path/to/IndoSynth-Gramin-Bank/data/customers.csv'
   ```
5. Execute the full script — it will create the schema, apply all 18 FK constraints, and bulk-load all 9 tables.
6. **Optionally**, run scripts `01` through `12` independently for step-by-step SQL learning.

### Step 3 — EDA & Visualizations (Phase 2)

```powershell
# Option A: Interactive Jupyter Notebooks (recommended for learning)
jupyter notebook eda/eda_preprocessing.ipynb     # Run first — creates cleaned_data/
jupyter notebook eda/eda_plotly.ipynb            # Run second — generates 42 charts

# Option B: Run as Python scripts (faster for just output)
python eda/eda_preprocessing.py   # Creates eda/cleaned_data/*.csv
python eda/eda_plotly.py          # Creates eda/charts/*.html
```

> Running `eda_plotly.py` / `eda_plotly.ipynb` saves all **42 interactive HTML charts** to `eda/charts/`. Open any `.html` file in a browser for full interactivity.

### Step 4 — Power BI Dashboard (Phase 3)

1. Open **Power BI Desktop**.
2. Open `PowerBI/IndoSynth Bank.pbix`.
3. If prompted to refresh data sources, update paths to point to `eda/cleaned_data/`.
4. The custom Rose Gold theme is already embedded in the `.pbix` file.
5. Use the left sidebar navigation to move between the 5 dashboard pages.

---

## 🛠️ Technology Stack

| Layer | Tools & Libraries | Version |
| :--- | :--- | :--- |
| **Database** | MySQL Server + MySQL Workbench | 8.0+ |
| **Core Language** | Python | 3.10+ |
| **Data Manipulation** | `pandas`, `numpy` | Latest stable |
| **Interactive Visualization** | `plotly.express`, `plotly.graph_objects`, `plotly.subplots` | Latest stable |
| **Statistical Testing** | `scipy.stats` | Latest stable |
| **Static Chart Export** | `kaleido` | Latest stable |
| **BI Dashboard** | Microsoft Power BI Desktop | March 2025+ |
| **Notebook Environment** | Jupyter Notebook, `ipykernel` | Latest stable |
| **IDE** | VS Code | Latest stable |
| **Version Control** | Git | Any |

---

## 📁 Key Files Reference

| File | Purpose |
| :--- | :--- |
| [`mysql/complete_mysql_script.sql`](mysql/complete_mysql_script.sql) | Master script: full schema DDL + all 18 FK constraints + bulk data load |
| [`mysql/12_KPIs.sql`](mysql/12_KPIs.sql) | Executive KPI SQL calculations matching Power BI DAX measures |
| [`mysql/07_Window_Functions.sql`](mysql/07_Window_Functions.sql) | Advanced window function queries: RANK, LAG, LEAD, NTILE |
| [`eda/eda_preprocessing.ipynb`](eda/eda_preprocessing.ipynb) | Fully documented 9-step preprocessing pipeline with output |
| [`eda/eda_plotly.ipynb`](eda/eda_plotly.ipynb) | All 42 Plotly charts + 4 statistical hypothesis tests with results |
| [`PowerBI/IndoSynth Bank.pbix`](PowerBI/IndoSynth%20Bank.pbix) | Power BI 5-page interactive dashboard with Rose Gold theme |
| [`PowerBI/IndoSynth_RoseGold_Theme.json`](PowerBI/IndoSynth_RoseGold_Theme.json) | Custom Power BI color theme file |
| [`business_analysis/documents/SRS.md`](business_analysis/documents/SRS.md) | Software Requirements Specification (FR-01 to FR-26) |
| [`business_analysis/documents/executive_summary.md`](business_analysis/documents/executive_summary.md) | Management-facing analytical findings report |
| [`business_analysis/documents/kpi_definitions.md`](business_analysis/documents/kpi_definitions.md) | Single source of truth for all KPI thresholds, DAX & SQL formulas |
| [`business_analysis/documents/stakeholder_analysis.md`](business_analysis/documents/stakeholder_analysis.md) | Stakeholder register, Power-Interest grid, RACI matrix & communication plan |
| [`business_analysis/sql_analysis/03_risk_profiling.sql`](business_analysis/sql_analysis/03_risk_profiling.sql) | NPA risk scoring and credit risk profiling queries |
| [`project_guide.md`](project_guide.md) | Full project specification & business objectives |
| [`powerbi_dashboard_specification.md`](powerbi_dashboard_specification.md) | Power BI build specification with DAX measures |

---

## ❓ FAQ & Troubleshooting

<details>
<summary><b>❓ I get a "local_infile" error when running the MySQL script. How do I fix it?</b></summary>

Run the following command in MySQL Workbench **before** executing the main script:
```sql
SET GLOBAL local_infile = 1;
```
Also, when starting MySQL Workbench connection, ensure the connection has "Allow Local Data Loading" enabled in the Advanced tab.

</details>

<details>
<summary><b>❓ The Plotly charts are not rendering in Jupyter Notebook. What's wrong?</b></summary>

Ensure you have `nbformat>=4.2.0` installed and that the correct kernel is selected:
```powershell
pip install --upgrade nbformat plotly ipykernel
python -m ipykernel install --user --name=venv
```
Then in Jupyter, select the `venv` kernel from the top-right kernel selector.

</details>

<details>
<summary><b>❓ Power BI shows a data source error when I open the .pbix file. How do I fix it?</b></summary>

1. In Power BI Desktop, go to **Home → Transform Data → Data Source Settings**.
2. Update the folder path for CSV sources to point to your local `eda/cleaned_data/` directory.
3. Click **Close & Apply** to refresh.

</details>

<details>
<summary><b>❓ The EDA preprocessing script is very slow. How can I speed it up?</b></summary>

The `transactions.csv` file is ~188MB and `loan_payments.csv` is ~82MB. You can speed up loading with:
```python
# Use dtype specification to avoid auto-detection overhead
df = pd.read_csv('data/transactions.csv', dtype={'transaction_id': int, 'amount': float})
```
The preprocessing notebooks already include memory-optimized loading. Ensure you have at least **4GB of free RAM** before running.

</details>

<details>
<summary><b>❓ How do I run only a specific SQL script (e.g., only Window Functions)?</b></summary>

All numbered scripts in `mysql/` are **self-contained and independent**. You can open any script (e.g., `07_Window_Functions.sql`) in MySQL Workbench and run it independently, assuming the database and tables already exist from running `01_Database_Setup.sql` or `complete_mysql_script.sql`.

</details>

<details>
<summary><b>❓ Can I use this project with a different database (PostgreSQL, SQL Server)?</b></summary>

The SQL scripts use MySQL-specific syntax (`LOAD DATA LOCAL INFILE`, `AUTO_INCREMENT`, `SHOW CREATE TABLE`). You would need to adapt these for other databases. The Python EDA layer is database-agnostic and works purely from CSV files.

</details>

---

## 🗺️ Project Roadmap

| Phase | Status | Deliverables |
|-------|--------|-------------|
| **Phase 1 — Database Layer** | ✅ Complete | MySQL schema (9 tables, 18 FKs), 12 SQL curriculum scripts, 5 business analysis SQL scripts |
| **Phase 2 — EDA & Python** | ✅ Complete | 9-step preprocessing pipeline, 42 Plotly charts, 4 hypothesis tests, 20+ engineered features |
| **Phase 3 — Power BI Dashboard** | ✅ Complete | 5-page interactive dashboard, Rose Gold theme, 40+ DAX measures |
| **Phase 4 — BA Documentation** | ✅ Complete | SRS, BRD, Executive Summary, KPI Definitions, Stakeholder Analysis |
| **Phase 5 — ML / Predictive (Future)** | 🔲 Planned | Credit default prediction model using engineered features from Phase 2 |
| **Phase 6 — Live Data Integration (Future)** | 🔲 Planned | Real-time CBS integration with automated refresh pipeline |

---

## 📝 License

This project is developed for **educational and professional portfolio demonstration purposes**. All data is synthetically generated and does not represent any real banking institution, individual, or financial data.

Feel free to use this project as a reference for your own portfolio. If you find it helpful, a ⭐ on the repository would be appreciated!

---

<div align="center">

**Built as a comprehensive end-to-end data analytics portfolio project**

*IndoSynth Gramin Bank — Driving rural financial intelligence through data*

---

📊 **MySQL** → 🐍 **Python** → 📈 **Power BI** → 💼 **Business Intelligence**

</div>
