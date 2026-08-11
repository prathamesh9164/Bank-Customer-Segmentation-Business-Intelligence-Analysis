# 📑 Software Requirements Specification (SRS)
## IndoSynth Gramin Bank — Data Analytics & Business Intelligence System

---

| Field               | Detail                                              |
|---------------------|-----------------------------------------------------|
| **Document ID**     | IGB-SRS-2026-v1.0                                  |
| **Version**         | 1.0                                                 |
| **Status**          | Approved                                            |
| **Prepared By**     | Business Analyst — Data & BI Team                  |
| **Date**            | August 2026                                         |
| **Project Code**    | IGB-BI-2026                                         |
| **Review Date**     | February 2027                                       |
| **Classification**  | Internal — Restricted                               |

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Overall Description](#2-overall-description)
3. [System Architecture](#3-system-architecture)
4. [Functional Requirements](#4-functional-requirements)
5. [Non-Functional Requirements](#5-non-functional-requirements)
6. [Data Requirements](#6-data-requirements)
7. [External Interface Requirements](#7-external-interface-requirements)
8. [KPI & Business Rules](#8-kpi--business-rules)
9. [Constraints & Assumptions](#9-constraints--assumptions)
10. [Appendix](#10-appendix)

---

## 1. Introduction

### 1.1 Purpose

This Software Requirements Specification (SRS) defines the complete functional and non-functional requirements for the **IndoSynth Gramin Bank (IGB) Data Analytics & Business Intelligence System**. The system is a 4-phase integrated analytics solution built to replace manual, Excel-based reporting with automated, reliable, and interactive insights across all stakeholder levels of the bank.

This document is intended for:
- Developers and data engineers implementing the system
- Business analysts validating requirements
- Stakeholders reviewing scope and deliverables
- QA teams designing test cases

### 1.2 Scope

The IGB BI System covers the following components:

| Component | Technology | Deliverable |
|-----------|-----------|-------------|
| **Phase 1 — Data Layer** | MySQL 8.0+ | Normalized relational database with 9 tables, ~2.9M records |
| **Phase 2 — EDA Layer** | Python (pandas, plotly) | Cleaned datasets, 30+ visualizations, 4 hypothesis tests |
| **Phase 3 — Dashboard Layer** | Power BI Desktop | 6-page interactive report with Rose Gold Light Theme |
| **Phase 4 — BA Analysis Layer** | SQL + Python | 5 analysis scripts, KPI tracker, HTML insight report |

**What is NOT in scope:**
- Real-time data streaming or live CBS (Core Banking System) integration
- Machine learning / predictive models (feature engineering only)
- Mobile application development
- Public-facing customer portal

### 1.3 Definitions, Acronyms & Abbreviations

| Term | Definition |
|------|-----------|
| **IGB** | IndoSynth Gramin Bank |
| **BI** | Business Intelligence |
| **EDA** | Exploratory Data Analysis |
| **KPI** | Key Performance Indicator |
| **NPA** | Non-Performing Asset (defaulted loans) |
| **UPI** | Unified Payments Interface (India's digital payment system) |
| **KYC** | Know Your Customer (regulatory identity verification) |
| **SRS** | Software Requirements Specification |
| **BRD** | Business Requirements Document |
| **DAX** | Data Analysis Expressions (Power BI formula language) |
| **CTE** | Common Table Expression (advanced SQL construct) |
| **3NF** | Third Normal Form (database normalization standard) |
| **CBS** | Core Banking System |
| **EMI** | Equated Monthly Installment |
| **GNPA** | Gross Non-Performing Assets ratio |
| **LPA** | Lakhs Per Annum (Rs. unit of annual income) |
| **Cr** | Crore (Rs. unit, 1 Cr = 10 million Rs.) |
| **NPCI** | National Payments Corporation of India |
| **RBI** | Reserve Bank of India |

### 1.4 References

| Document | Location |
|----------|----------|
| Business Requirements Document (BRD) | `business_analysis/documents/business_requirements.md` |
| KPI Definitions & Governance Dictionary | `business_analysis/documents/kpi_definitions.md` |
| Executive Summary — Data Analytics Findings | `business_analysis/documents/executive_summary.md` |
| Power BI Dashboard Master Specification | `powerbi_dashboard_specification.md` |
| SQL Analysis Scripts (5 files) | `business_analysis/sql_analysis/` |
| BA Insight Report Generator | `business_analysis/python_reports/ba_insight_report.py` |
| Project Guide | `project_guide.md` |
| README | `README.md` |

---

## 2. Overall Description

### 2.1 Product Perspective

IndoSynth Gramin Bank operates **250 branches** across rural, semi-urban, and urban India, serving **100,000+ customers** with a portfolio of **300,000+ loan applications** and **1.5 million+ transactions** annually. Prior to this system, the bank faced:

| Pain Point | Impact |
|-----------|--------|
| Delayed NPA detection | Defaults identified weeks after occurrence |
| Siloed branch reporting | No network-wide trend visibility for managers |
| No digital adoption tracking | UPI growth not quantified or strategized |
| Manual KPI reporting | Weekly Excel reports — error-prone and stale |
| No segment profitability view | Revenue concentration unknown |

The IGB BI System eliminates these gaps through an end-to-end analytics pipeline.

### 2.2 Product Functions (High-Level)

1. **Ingest & Store** — Load all 9 operational CSV tables into a normalized MySQL database
2. **Clean & Validate** — Perform automated EDA, imputation, and feature engineering
3. **Analyze & Visualize** — Run SQL analytical queries and Python statistical analyses
4. **Report & Monitor** — Deliver interactive Power BI dashboards and automated HTML reports
5. **Alert & Govern** — Track all KPIs against defined thresholds with traffic-light status

### 2.3 User Classes & Characteristics

| User Class | Technical Level | Primary Interaction | Volume |
|-----------|----------------|--------------------|----|
| **MD / CEO** | Low | Power BI — Executive Page | 1 |
| **CFO / Finance Head** | Low | Power BI — Executive + Loan Pages | 1 |
| **Chief Risk Officer** | Medium | Power BI — Risk Monitoring Page | 1 |
| **Head of Retail Banking** | Medium | Power BI — Customer 360 Page | 1 |
| **Head of Credit** | Medium | Power BI — Loan Performance Page | 1 |
| **Head of Digital Banking** | Medium | Power BI — Transactions Page | 1 |
| **Zonal Managers** | Medium | Power BI — Branch Ops Page (zone-filtered) | 5 |
| **Branch Managers** | Low | Power BI — Branch Ops Page (branch-filtered) | 250 |
| **Compliance Officer** | Medium | Power BI — Customer 360 (KYC metrics) | 1 |
| **IT / Data Team** | High | MySQL, Python scripts, Power BI data model | ~5 |
| **Business Analyst** | High | All layers — SQL, Python, Power BI authoring | ~2 |

### 2.4 Operating Environment

| Layer | Technology | Version | Host |
|-------|-----------|---------|------|
| Database | MySQL | 8.0+ | Local / On-prem server |
| Python Runtime | CPython | 3.10+ | Local workstation |
| Dashboard | Power BI Desktop | March 2025+ | Local workstation |
| Dashboard (distribution) | Power BI Service | Current | Cloud (Microsoft) |
| OS | Windows | 10/11 | Standard bank workstation |

### 2.5 Design & Implementation Constraints

- All tools must be free/open-source or already licensed (no additional licensing cost)
- Python environment is managed via `venv` with dependencies in `requirements.txt`
- Data is batch-refreshed (not real-time)
- Raw data contains no PII beyond internal bank-issued IDs

---

## 3. System Architecture

### 3.1 Architecture Overview

```
+----------------------------------------------------------+
|                     RAW DATA SOURCE                       |
|          9 CSV Files (~2.9 Million Records)               |
+-----------------------------+----------------------------+
                              | LOAD DATA LOCAL INFILE
                              v
+----------------------------------------------------------+
|                  PHASE 1 -- MySQL Layer                   |
|     Normalized 3NF schema · 9 tables · 18 FK relations    |
+----------+-----------------------------+-----------------+
           | Python reads CSV            | SQL reads MySQL
           v                             v
+--------------------+    +--------------------------------+
|  PHASE 2 -- EDA    |    |  PHASE 4 -- BA SQL Analysis   |
|  pandas · plotly   |    |  5 scripts · CTEs · Windows   |
|  Cleaned CSVs      |    |  Customer/Loan/Risk/Branch     |
+----------+---------+    +--------------------------------+
           | Cleaned CSV exports
           v
+----------------------------------------------------------+
|              PHASE 3 -- Power BI Dashboard                |
|   Star Schema · 40+ DAX Measures · 6 Pages               |
|   Rose Gold Light Theme · Cross-filter · Drill-through    |
+----------------------------------------------------------+
           | Python reads cleaned CSVs
           v
+----------------------------------------------------------+
|        PHASE 4 -- Python BA Insight Report                |
|   ba_insight_report.py  -->  ba_report.html              |
|   6 automated analyses · Plotly embedded charts           |
+----------------------------------------------------------+
```

### 3.2 Database Schema (MySQL)

The database uses a **Star Schema** with the following tables:

**Fact Tables:**

| Table | Primary Key | Key Foreign Keys | ~Row Count |
|-------|------------|-----------------|-----------|
| `loan_applications` | `application_id` | `customer_id`, `branch_id`, `loan_type_id`, `employee_id` | 300,000 |
| `loan_payments` | `payment_id` | `application_id` | 900,000 |
| `transactions` | `transaction_id` | `customer_id`, `branch_id` | 1,500,000 |

**Dimension Tables:**

| Table | Primary Key | ~Row Count |
|-------|------------|-----------|
| `customers` | `customer_id` | 100,000 |
| `credit_history` | `credit_id` | 100,000 |
| `branches` | `branch_id` | 250 |
| `employees` | `employee_id` | 2,000 |
| `regions` | `region_id` | 40 |
| `loan_types` | `loan_type_id` | 10 |

**Total: ~2.9 Million Records across 9 tables with 18 defined FK relationships**

### 3.3 Power BI Data Model

The Power BI data model mirrors the MySQL schema with an added `dim_Date` calendar table:

- **Import mode** (not DirectQuery) for performance
- **Star schema** with dimensions on the `1` side and facts on the `*` side
- **Cross-filter direction**: Single (`1 → *`) for all relationships
- **`dim_Date`** generated via DAX CALENDAR() function, connected to all fact tables via date columns

---

## 4. Functional Requirements

### 4.1 FR-01 to FR-05 — Data Layer (MySQL)

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| **FR-01** | The system shall import all 9 raw CSV tables into a normalized MySQL database with properly typed columns (PK as `INT NOT NULL`, dates as `DATE`, text as `VARCHAR`) | Must Have | `DESCRIBE <table>` for all 9 tables |
| **FR-02** | Foreign key relationships shall enforce referential integrity across all 18 defined `FOREIGN KEY` constraints | Must Have | `SHOW CREATE TABLE` on all tables |
| **FR-03** | Date columns shall be stored as MySQL `DATE` type; no date stored as text | Must Have | `information_schema.COLUMNS` check |
| **FR-04** | Bulk load mechanism (`LOAD DATA LOCAL INFILE`) shall ingest the full 2.9M+ row dataset in under 10 minutes | Should Have | Timed execution log |
| **FR-05** | Schema shall comply with 3NF — no transitive functional dependencies, no repeating groups | Must Have | Schema review against 3NF rules |

### 4.2 FR-06 to FR-11 — EDA & Python Layer

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| **FR-06** | The system shall execute a 9-step automated preprocessing pipeline on all 9 raw tables (null handling, type casting, deduplication, range validation, derived features) | Must Have | Pipeline log output per table |
| **FR-07** | Domain-aware imputation shall set `rejection_reason = 'N/A'` for all loan applications where `status != 'Rejected'` | Must Have | Count query must return 0 violations |
| **FR-08** | The EDA layer shall generate a minimum of 30 interactive Plotly visualizations covering 6 thematic sections (Customer, Loan, Payment, Credit, Transaction, Branch) | Should Have | HTML output file visual count |
| **FR-09** | Four statistical hypothesis tests shall be conducted with documented null hypothesis, test statistic, p-value, and conclusion: (1) income vs loan amount, (2) credit score vs default rate, (3) branch type vs processing time, (4) digital usage vs repayment rate | Should Have | Printed test results in output |
| **FR-10** | Feature engineering shall produce a minimum of 20 derived attributes including: `age_group`, `income_band`, `credit_band`, `loan_to_income_ratio`, `upi_share_pct`, `tenure_months` | Must Have | Column count in cleaned CSVs |
| **FR-11** | All cleaned CSV outputs shall be exported to `eda/cleaned_data/` directory for downstream consumption by Power BI and Python reports | Must Have | File existence check in `eda/cleaned_data/` |

### 4.3 FR-12 to FR-20 — Power BI Dashboard Layer

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| **FR-12** | The dashboard shall contain exactly 6 named pages: (1) Executive Summary, (2) Customer 360, (3) Loan Performance, (4) Risk Monitoring, (5) Transactions & Digital, (6) Branch Operations | Must Have | Page count in .pbix |
| **FR-13** | All pages shall apply the Rose Gold Light Theme — canvas `#FFF5F0`, containers `#FFFFFF`, header/sidebar `#B76E79` | Must Have | Visual inspection + theme JSON |
| **FR-14** | A universal `dim_Date[YearMonth]` slicer shall be present on every page and shall filter all visuals on that page | Must Have | Slicer interaction test on all 6 pages |
| **FR-15** | A left navigation sidebar (70px wide, `#B76E79` background) shall be present on all 6 pages with page-navigation buttons | Must Have | Button action test per page |
| **FR-16** | A minimum of 40 DAX measures shall be created in a dedicated `_Measures` table, covering all KPIs in `kpi_definitions.md` | Must Have | Measure count in Fields pane |
| **FR-17** | All KPI card visuals shall display conditional formatting using the threshold bands defined in `kpi_definitions.md` (Green / Amber / Red) | Must Have | KPI card color test at boundary values |
| **FR-18** | Page 6 (Branch Operations) shall include a geographic map visual with state/zone-level loan disbursement bubbles sized by portfolio volume | Should Have | Visual inspection of map page |
| **FR-19** | The Power BI report shall fully load (all visuals rendered) within 8 seconds on a standard workstation (Intel i5, 8 GB RAM) | Should Have | Stopwatch test on cold open |
| **FR-20** | Clicking any segment on a categorical visual shall cross-filter all other visuals on the same page | Must Have | Click-test on 3 visuals per page |

### 4.4 FR-21 to FR-26 — Business Analysis (BA) Layer

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| **FR-21** | Five SQL analysis scripts shall answer defined business questions using advanced SQL (CTEs, window functions, subqueries): Customer Segmentation, Loan Funnel, Risk Profiling, Branch Performance, Digital Transformation | Should Have | Script execution without errors |
| **FR-22** | The Python KPI tracker shall compute all 12 KPIs from cleaned data and compare each against its defined threshold, outputting a Green / Yellow / Red status | Should Have | KPI tracker output validation |
| **FR-23** | `ba_insight_report.py` shall generate a self-contained HTML file (`ba_report.html`) containing 6 embedded Plotly charts and business insight text | Should Have | HTML file opens in browser without errors |
| **FR-24** | The `kpi_definitions.md` governance document shall align DAX measure names, SQL formulas, thresholds, and owners for all 12 defined KPIs | Must Have | Cross-reference audit between KPI doc and DAX/SQL |
| **FR-25** | All SQL scripts shall include inline comments explaining the business context of each major CTE and query block | Should Have | Code review |
| **FR-26** | The BA Insight Report shall run on Windows with Python 3.10+ and produce no errors or encoding exceptions when executed | Must Have | Script exit code = 0 |

---

## 5. Non-Functional Requirements

### 5.1 Performance Requirements

| ID | Requirement | Metric |
|----|-------------|--------|
| **NFR-P1** | Power BI report shall fully load within **8 seconds** on cold open | Stopwatch: <= 8s |
| **NFR-P2** | Power BI dataset refresh (all 9 tables) shall complete within **30 seconds** | Refresh log: <= 30s |
| **NFR-P3** | MySQL bulk data load for 2.9M rows shall complete within **10 minutes** | Execution timer: <= 10 min |
| **NFR-P4** | Python EDA preprocessing pipeline shall process all 9 tables within **5 minutes** | Script runtime: <= 5 min |
| **NFR-P5** | `ba_insight_report.py` shall generate the HTML report within **3 minutes** | Script runtime: <= 3 min |

### 5.2 Usability Requirements

| ID | Requirement |
|----|-------------|
| **NFR-U1** | The Power BI dashboard shall be operable by a non-technical stakeholder after no more than **30 minutes of orientation** |
| **NFR-U2** | All KPI cards shall include a subtitle or tooltip explaining what the metric measures |
| **NFR-U3** | Navigation buttons shall be labeled with page names AND icons (not icons alone) |
| **NFR-U4** | The dashboard shall function correctly on both Power BI Desktop (authoring) and Power BI Service (distribution) |
| **NFR-U5** | Color choices shall maintain WCAG AA contrast ratio (>= 4.5:1) for all text-on-background combinations |

### 5.3 Reliability & Data Quality Requirements

| ID | Requirement | Threshold |
|----|-------------|-----------|
| **NFR-R1** | Cleaned datasets shall have **< 0.1% null rate** on all primary key columns | Validated via IS NULL count query |
| **NFR-R2** | Credit score values in `credit_history` shall be within the range **300–850** only | Range check query |
| **NFR-R3** | All loan amounts shall be **> 0** | Positive value check |
| **NFR-R4** | `loan_applications.status` shall be restricted to 5 allowed values only | Allowed values check |
| **NFR-R5** | `branches.branch_type` shall be restricted to: Rural, Semi-Urban, Urban only | Allowed values check |
| **NFR-R6** | `transactions.amount` values shall all be **> 0** | Positive value check |
| **NFR-R7** | All foreign key references shall resolve — no orphan records after cleaning | FK integrity check |

### 5.4 Maintainability Requirements

| ID | Requirement |
|----|-------------|
| **NFR-M1** | All SQL scripts shall include a header block with: script name, author, date, purpose, and table dependencies |
| **NFR-M2** | All Python functions shall include docstrings describing parameters, return values, and business purpose |
| **NFR-M3** | `kpi_definitions.md` must be updated whenever any KPI formula, threshold, or owner changes — before the change is deployed |
| **NFR-M4** | Power BI DAX measures shall be organized into display folders by category (Customer KPIs, Loan KPIs, Risk KPIs, etc.) |
| **NFR-M5** | The project shall maintain a `requirements.txt` with pinned library versions for reproducible Python environments |

### 5.5 Security & Compliance Requirements

| ID | Requirement |
|----|-------------|
| **NFR-S1** | Raw CSV files shall not contain real customer names, Aadhaar numbers, PAN numbers, or any PII beyond internal bank-issued IDs |
| **NFR-S2** | MySQL credentials shall not be hardcoded in any Python script — loaded from environment variables or config file excluded from version control |
| **NFR-S3** | The `.gitignore` file shall exclude: `venv/`, raw data CSVs, `.env` files, and credential files |
| **NFR-S4** | KYC compliance rate shall be monitored and reported — RBI mandates 100% KYC compliance |

### 5.6 Compatibility Requirements

| ID | Requirement |
|----|-------------|
| **NFR-C1** | Dashboard `.pbix` file shall open without errors in Power BI Desktop (March 2025+) |
| **NFR-C2** | Python scripts shall run on Python 3.10+ with Windows 10/11 |
| **NFR-C3** | Python stdout/stderr shall be configured as UTF-8 to handle Unicode characters on Windows cp1252 terminals |
| **NFR-C4** | MySQL scripts shall be compatible with MySQL 8.0+ syntax |
| **NFR-C5** | All generated HTML reports shall render correctly in Chromium-based browsers without plugins |

---

## 6. Data Requirements

### 6.1 Input Data Specification

| Table (CSV File) | Rows | Key Columns | Data Period |
|-----------------|------|------------|------------|
| `customers_cleaned.csv` | ~100,000 | `customer_id`, `annual_income`, `kyc_status`, `state`, `branch_id` | FY 2018–2025 |
| `credit_history_cleaned.csv` | ~100,000 | `customer_id`, `credit_score`, `credit_band` | FY 2018–2025 |
| `loan_apps_cleaned.csv` | ~300,000 | `application_id`, `customer_id`, `loan_amount_approved`, `status`, `rejection_reason` | FY 2018–2025 |
| `loan_payments_cleaned.csv` | ~900,000 | `payment_id`, `application_id`, `payment_status`, `days_late`, `outstanding_balance` | FY 2018–2025 |
| `transactions_cleaned.csv` | ~1,500,000 | `transaction_id`, `customer_id`, `transaction_mode`, `amount`, `status` | FY 2018–2025 |
| `branches_cleaned.csv` | 250 | `branch_id`, `branch_name`, `branch_type`, `region_id` | Static |
| `employees_cleaned.csv` | 2,000 | `employee_id`, `branch_id`, `designation` | Static |
| `regions_cleaned.csv` | 40 | `region_id`, `zone` | Static |
| `loan_types_cleaned.csv` | 10 | `loan_type_id`, `loan_type_name` | Static |

### 6.2 Data Quality Acceptance Criteria

| Table | Column | Acceptance Rule |
|-------|--------|----------------|
| `customers` | `customer_id` | 0 nulls · 0 duplicates |
| `customers` | `annual_income` | All values > 0 · No negatives |
| `customers` | `kyc_status` | Values: Verified, Pending, Rejected only |
| `loan_applications` | `loan_amount_requested` | All values > 0 |
| `loan_applications` | `status` | Values: Pending, Under Review, Approved, Disbursed, Rejected only |
| `loan_applications` | `rejection_reason` | 'N/A' for all non-Rejected applications |
| `loan_payments` | `days_late` | Null allowed for Pending; numeric for Paid / Missed / Late |
| `credit_history` | `credit_score` | Range: 300–850 only |
| `transactions` | `amount` | All values > 0 |
| `branches` | `branch_type` | Values: Rural, Semi-Urban, Urban only |

### 6.3 Derived / Engineered Features (Minimum Required)

| Feature Column | Source Table | Derivation Logic |
|---------------|-------------|-----------------|
| `age_group` | `customers` | Bucketed from `age` (e.g., 18–25, 26–35, 36–50, 50+) |
| `income_band` | `customers` | Bucketed from `annual_income` (Low <3L, Mid 3–6L, High 6–12L, Premium 12L+) |
| `credit_band` | `credit_history` | Bucketed from `credit_score` (Poor <580, Fair 580–669, Good 670–739, Excellent 740+) |
| `loan_to_income_ratio` | `loan_applications` + `customers` | `loan_amount_approved / annual_income` |
| `upi_share_pct` | `transactions` | `UPI transactions / total transactions` per customer |
| `tenure_months` | `loan_applications` | Derived from `start_date` to `end_date` |
| `is_high_risk` | `credit_history` | Boolean: `credit_score < 600` |
| `profitability_index` | `loan_applications` + `loan_payments` | `interest_earned / loan_amount_approved` |

---

## 7. External Interface Requirements

### 7.1 Power BI Dashboard — Page Specification

| Page # | Name | Primary Audience | Key Visuals |
|--------|------|-----------------|------------|
| 1 | Executive Summary | MD, CFO | 8 headline KPI cards, trend chart, approval & default gauges, zone map |
| 2 | Customer 360 | Retail Banking Head, Compliance | Segment bar chart, income distribution, KYC donut, state map, age pyramid |
| 3 | Loan Performance | Head of Credit | Application funnel waterfall, loan type split, approval trend, rejection reason Pareto |
| 4 | Risk Monitoring | Chief Risk Officer | Default rate gauge, credit band scatter, NPA trend, high-risk customer table |
| 5 | Transactions & Digital | Head of Digital | UPI adoption area chart, transaction mode donut, volume trend, channel success rate |
| 6 | Branch Operations | Zonal/Branch Managers | Branch scatter (volume vs default), top/bottom branch table, processing days bar, geo map |

**Global Layout Rules:**
- Canvas: 1280 x 720 px (16:9)
- Background: `#FFF5F0` (Rose Cream)
- Grid Unit: 8px spacing between all visual containers
- Container Style: White (`#FFFFFF`) background, `1px #F2D7D0` border, `8px` rounded corners, drop shadow
- Font: Segoe UI across all text elements

### 7.2 Software Interface Requirements

| Interface | Specification |
|-----------|--------------|
| **MySQL ODBC** | Power BI connects via MySQL ODBC 8.0 Unicode Driver or imports from cleaned CSVs |
| **Python Libraries** | `pandas >= 1.5`, `numpy >= 1.20`, `plotly >= 5.0`, `scipy >= 1.9` |
| **Power BI Version** | Desktop March 2025+ · Power BI Service for distribution |
| **Browser (HTML report)** | Chrome 110+ / Edge 110+ (Chromium-based) |

### 7.3 Communication Interfaces

- **Data Refresh**: Batch-based, manual trigger or scheduled via Power BI Service
- **Report Distribution**: Power BI Service Workspace or shared `.pbix` file
- **HTML Report**: Generated locally, distributed as email attachment or shared drive link

---

## 8. KPI & Business Rules

### 8.1 KPI Definition Summary

> All KPIs are fully defined in `kpi_definitions.md`. This table is the governance summary.

| KPI ID | Name | Formula (Summary) | Green | Yellow | Red | Owner |
|--------|------|-------------------|-------|--------|-----|-------|
| KPI-C1 | Total Customers | COUNT(customer_id) | N/A | N/A | N/A | Retail Banking |
| KPI-C2 | Active Customer % | Active / Total * 100 | >= 85% | 75–84% | < 75% | Retail Banking |
| KPI-C3 | KYC Verified % | Verified / Total * 100 | >= 90% | 80–89% | < 80% | Compliance |
| KPI-C4 | Avg Annual Income | AVG(annual_income) / 100000 | N/A | N/A | N/A | Retail Banking |
| KPI-L1 | Approval Rate % | (Approved + Disbursed) / Total * 100 | >= 60% | 45–59% | < 45% | Credit |
| KPI-L2 | Disbursement Rate % | Disbursed / Total * 100 | >= 55% | 40–54% | < 40% | Loan Ops |
| KPI-L3 | Total Disbursed Portfolio | SUM(loan_amount_approved) / 10,000,000 | >= Rs.300 Cr | Rs.200–299 Cr | < Rs.200 Cr | CFO |
| KPI-R1 | Default Rate % | Missed Payments / Total EMI * 100 | <= 5% | 5–10% | > 10% | Risk Officer |
| KPI-R2 | On-Time Payment Rate % | On-Time EMI / Total EMI * 100 | >= 85% | 75–84% | < 75% | Collections |
| KPI-R3 | Total Outstanding Balance | SUM(outstanding_balance) / 10,000,000 | N/A | N/A | N/A | Finance |
| KPI-T1 | UPI Adoption Share % | UPI Txns / Total Txns * 100 | >= 60% | 40–59% | < 40% | Digital Banking |
| KPI-T2 | Transaction Success Rate % | Success Txns / Total Txns * 100 | >= 97% | 92–96% | < 92% | Tech Ops |

> **Governance Rule**: Any change to a KPI formula, threshold, or ownership **must** be reflected in `kpi_definitions.md`, the Power BI DAX measure, and the SQL script simultaneously.

### 8.2 Business Rules

| Rule ID | Rule |
|---------|------|
| **BR-01** | `rejection_reason` must be 'N/A' for all non-Rejected loan applications |
| **BR-02** | Credit score range is strictly 300–850 (CIBIL scale); values outside this range are invalid |
| **BR-03** | Loan status transitions are one-directional: Pending → Under Review → Approved → Disbursed (or Rejected from any stage) |
| **BR-04** | `days_late = 0` means payment was made exactly on due date (not late) |
| **BR-05** | `payment_status = 'Missed'` is the sole indicator for NPA calculation in Default Rate % |
| **BR-06** | `branch_type` determines processing SLA: Rural = 22-day benchmark, Urban = 13-day benchmark |
| **BR-07** | UPI share above 60% per customer qualifies as "Heavy Digital" tier; used in risk correlation |
| **BR-08** | A customer with `credit_score < 600` is classified as `is_high_risk = True` |
| **BR-09** | `profitability_index = interest_earned / loan_amount_approved`; >= 0.15 = High Profit, 0.08–0.14 = Medium, < 0.08 = Low |

---

## 9. Constraints & Assumptions

### 9.1 Constraints

| Category | Constraint |
|----------|-----------|
| **Budget** | Portfolio/educational initiative — zero additional licensing budget |
| **Tools** | Fixed technology stack: MySQL 8.0, Python 3.10+, Power BI Desktop |
| **Data** | Batch refresh only — no real-time streaming or live CBS connection |
| **Timeline** | 4-phase sequential delivery (Phase 1 → 2 → 3 → 4) |
| **Environment** | Windows OS workstations only |
| **Data Volume** | Designed for up to ~5M records; beyond this, performance NFRs must be re-evaluated |

### 9.2 Assumptions

| ID | Assumption |
|----|-----------|
| **A-01** | All 9 CSV files accurately represent operational data for FY 2018–2025 |
| **A-02** | Power BI workspace has map visuals enabled (Bing Maps turned on) |
| **A-03** | Python virtual environment is correctly configured from `requirements.txt` before running any scripts |
| **A-04** | Cleaned CSVs are always read from `eda/cleaned_data/` — if this directory is missing, all downstream tools will fail |
| **A-05** | Power BI Desktop (March 2025+ version) is installed on the analyst workstation |
| **A-06** | MySQL 8.0+ is installed and the `indosynth_bank` database is created before running SQL scripts |
| **A-07** | Data in the CSVs does not represent any real individual's personal financial data |
| **A-08** | The `regions` table contains a `zone` column; if absent, branch analysis falls back to `branch_type` |

---

## 10. Appendix

### 10.1 SQL Analysis Scripts Index

| Script | File | Business Question Answered |
|--------|------|---------------------------|
| Customer Segmentation | `01_customer_segmentation.sql` | Which segments are most profitable? Top states by customer value? |
| Loan Funnel Analysis | `02_loan_funnel_analysis.sql` | Where is the largest drop-off from application to disbursement? |
| Risk Profiling | `03_risk_profiling.sql` | How does credit band correlate with default rate? Who are the high-risk borrowers? |
| Branch Performance | `04_branch_performance.sql` | Which branches have highest volume and lowest defaults? Processing time variance? |
| Digital Transformation | `05_digital_transformation.sql` | How has UPI adoption evolved? Does digital usage predict repayment behaviour? |

### 10.2 File & Directory Structure

```
B:\Major Project\
├── IndoSynth Bank.pbix                         # Power BI dashboard
├── powerbi_dashboard_specification.md          # Dashboard pixel blueprint
├── project_guide.md                            # Project walkthrough guide
├── README.md                                   # Project overview
├── requirements.txt                            # Python dependencies
├── IndoSynth_RoseGold_Theme.json              # Power BI theme file
├── data/                                       # Raw source CSVs
├── eda/
│   └── cleaned_data/                           # Cleaned CSVs (EDA output)
├── mysql/                                      # MySQL schema & load scripts
├── business_analysis/
│   ├── documents/
│   │   ├── SRS.md                             <- This document
│   │   ├── business_requirements.md           # BRD
│   │   ├── kpi_definitions.md                 # KPI Governance Dictionary
│   │   └── executive_summary.md               # Executive analytics findings
│   ├── sql_analysis/
│   │   ├── 01_customer_segmentation.sql
│   │   ├── 02_loan_funnel_analysis.sql
│   │   ├── 03_risk_profiling.sql
│   │   ├── 04_branch_performance.sql
│   │   └── 05_digital_transformation.sql
│   ├── python_reports/
│   │   └── ba_insight_report.py               # Generates ba_report.html
│   └── output/
│       └── ba_report.html                     # Generated HTML report
└── venv/                                       # Python virtual environment
```

### 10.3 Document Revision History

| Version | Date | Author | Change Description |
|---------|------|--------|--------------------|
| v1.0 | August 2026 | Business Analyst — IGB BI Team | Initial SRS created |

---

### 10.4 Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Business Analyst | — | _______________ | Aug 2026 |
| Project Sponsor | — | _______________ | Aug 2026 |
| Data Lead | — | _______________ | Aug 2026 |
| Chief Risk Officer | — | _______________ | Aug 2026 |

---

*Document Owner: Business Analysis Team · IndoSynth Gramin Bank BI Project*
*Standard: IEEE 830 / ISO/IEC 29148 aligned*
*Last Reviewed: August 2026 · Next Review: February 2027*
