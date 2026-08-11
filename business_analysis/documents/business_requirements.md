# 📋 Business Requirements Document (BRD)
## IndoSynth Gramin Bank — Data Analytics & BI Solution

| Field | Detail |
|-------|--------|
| **Document Version** | v1.0 |
| **Prepared By** | Business Analyst — Data & BI Team |
| **Date** | August 2026 |
| **Status** | Approved |
| **Project Code** | IGB-BI-2026 |

---

## 1. Executive Summary

IndoSynth Gramin Bank (IGB) operates a network of **250 branches** across rural, semi-urban, and urban India, serving **100,000+ customers** with a portfolio of **300,000+ loan applications** and **1.5 million transactions** annually. The bank lacks a unified, real-time analytics infrastructure, resulting in:

- **Delayed risk detection** — NPA (Non-Performing Asset) defaults identified weeks after they occur
- **Siloed reporting** — branch managers operate without visibility into network-wide trends
- **No digital adoption tracking** — UPI growth not quantified or strategized
- **Manual KPI reporting** — weekly Excel-based reports that are error-prone and stale

This project delivers a **3-phase integrated analytics solution** (MySQL → Python EDA → Power BI) to replace manual processes with automated, reliable, and interactive insights for all stakeholder levels.

---

## 2. Project Scope

### 2.1 In Scope
- Design and populate a **normalized MySQL relational database** from 9 raw CSV datasets
- Perform **Exploratory Data Analysis (EDA)** to validate, clean, and feature-engineer the data
- Build a **6-page interactive Power BI dashboard** (Executive, Customers, Loans, Risk, Transactions, Branches)
- Create a **BA analysis layer** with SQL queries, automated Python reports, and KPI monitoring

### 2.2 Out of Scope
- Real-time data streaming or live database connections (batch/scheduled refresh only)
- Predictive machine learning models (beyond feature engineering for future use)
- Mobile application development
- Integration with the bank's core banking system (CBS)

---

## 3. Stakeholder Map

| Stakeholder | Role | Primary Interest | Dashboard Pages |
|-------------|------|-----------------|-----------------|
| **MD / CEO** | Executive Sponsor | Bank-wide health, portfolio growth | Page 1 (Executive Summary) |
| **CFO / Finance Head** | Decision Maker | Revenue, interest income, cost of risk | Page 1, Page 3 |
| **Chief Risk Officer** | Decision Maker | NPA rate, default trends, exposure | Page 4 (Risk Monitoring) |
| **Head of Retail Banking** | Primary User | Customer growth, segment profitability | Page 2 (Customer 360°) |
| **Head of Credit** | Primary User | Approval rate, rejection reasons, funnel | Page 3 (Loan Performance) |
| **Head of Digital Banking** | Primary User | UPI adoption, transaction volumes | Page 5 (Transactions) |
| **Zonal Managers (5)** | Regular User | Zone performance vs targets | Page 6 (Branch Ops) |
| **Branch Managers (250)** | Regular User | Branch-level KPIs, officer performance | Page 6 |
| **Compliance Officer** | Auditor | KYC verification, data completeness | Page 2 |
| **IT / Data Team** | Implementers | Data pipeline, refresh schedules | All pages (technical) |

---

## 4. Business Objectives & Success Metrics

| Objective | KPI | Current State | Target (12 months) |
|-----------|-----|--------------|-------------------|
| Reduce NPA rate | Default Rate % | Unknown (manual) | ≤ 5.0% |
| Improve loan throughput | Disbursement Rate % | Unknown | ≥ 55% |
| Accelerate processing | Avg Days to Disburse | Unknown | ≤ 15 days |
| Grow digital adoption | UPI Adoption Share % | Unknown | ≥ 60% |
| Ensure customer quality | KYC Verified % | Unknown | ≥ 92% |
| Improve collections | On-Time Payment Rate % | Unknown | ≥ 87% |

---

## 5. Functional Requirements

### 5.1 Data Layer (MySQL)

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | System shall import all 9 raw CSV tables into a normalized MySQL database with PK/FK constraints | Must Have |
| FR-02 | Foreign key relationships shall enforce referential integrity across all 18 defined relationships | Must Have |
| FR-03 | Date columns shall be stored as `DATE` type; ID columns shall be `INT NOT NULL` | Must Have |
| FR-04 | A bulk load mechanism (`LOAD DATA LOCAL INFILE`) shall ingest 2.9M+ records within 10 minutes | Should Have |
| FR-05 | System shall support 3NF normalized schema with no transitive dependencies | Must Have |

### 5.2 EDA / Python Layer

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-06 | System shall perform automated 9-step preprocessing pipeline on all 9 tables | Must Have |
| FR-07 | Domain-aware imputation shall fill `rejection_reason` = 'N/A' for non-rejected loans | Must Have |
| FR-08 | System shall generate 30+ interactive Plotly visualizations across 6 thematic sections | Should Have |
| FR-09 | 4 statistical hypothesis tests shall be conducted and results documented | Should Have |
| FR-10 | Feature engineering shall produce 20+ derived attributes (age_group, credit_band, etc.) | Must Have |
| FR-11 | Cleaned output shall be exported to `eda/cleaned_data/` for downstream use | Must Have |

### 5.3 Power BI Dashboard Layer

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-12 | Dashboard shall contain exactly 6 pages as specified in the dashboard specification | Must Have |
| FR-13 | All pages shall share a consistent **Rose Gold Light Theme** (`#FFF5F0` canvas) | Must Have |
| FR-14 | A universal date range slicer (`dim_Date[YearMonth]`) shall filter all visuals | Must Have |
| FR-15 | Page navigation sidebar shall be present on all 6 pages with page-level button actions | Must Have |
| FR-16 | 40+ DAX measures shall be created in a dedicated `_Measures` table | Must Have |
| FR-17 | All KPI cards shall display conditional formatting colors (Green/Amber/Red) | Must Have |
| FR-18 | Geographical map visual shall show state/zone-level loan disbursement bubbles | Should Have |
| FR-19 | Dashboard shall load within 8 seconds on a standard workstation | Should Have |
| FR-20 | All visuals shall cross-filter correctly (clicking a segment filters all visuals on the page) | Must Have |

### 5.4 Business Analysis Layer

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-21 | 5 SQL analysis scripts shall answer defined business questions using advanced SQL (CTEs, window functions) | Should Have |
| FR-22 | Python KPI tracker shall compute all 12 KPIs and compare against defined thresholds | Should Have |
| FR-23 | BA Insight Report shall generate a standalone HTML report from cleaned data | Nice to Have |
| FR-24 | KPI definitions document shall align measure names between DAX formulas and SQL scripts | Must Have |

---

## 6. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| **Performance** | Power BI report refreshes within 30 seconds with full 3M row dataset |
| **Usability** | Dashboard operable by non-technical stakeholders without training beyond 30 minutes |
| **Maintainability** | All SQL scripts and Python code must be commented with business context |
| **Data Quality** | Cleaned datasets must have < 0.1% null rate on all primary key columns |
| **Compatibility** | Dashboard compatible with Power BI Desktop (March 2025+) and Power BI Service |
| **Security** | Raw CSVs shall not contain personally identifiable information (PII) beyond bank-internal IDs |

---

## 7. Data Quality Acceptance Criteria

| Table | Column | Acceptance Criterion |
|-------|--------|---------------------|
| `customers` | `customer_id` | 0 nulls, 0 duplicates |
| `customers` | `annual_income` | All values > 0, no negative values |
| `loan_applications` | `loan_amount_requested` | All values > 0 |
| `loan_applications` | `status` | Only: Pending, Under Review, Approved, Disbursed, Rejected |
| `loan_payments` | `days_late` | Null allowed for Pending; numeric for Paid/Missed/Late |
| `credit_history` | `credit_score` | Range 300–850 only |
| `transactions` | `amount` | All values > 0 |
| `branches` | `branch_type` | Only: Rural, Semi-Urban, Urban |

---

## 8. Assumptions & Constraints

**Assumptions:**
- All 9 CSV files accurately represent the bank's operational data for FY 2018–2025
- The Power BI workspace has access to map visuals (Bing Maps enabled)
- Python environment includes pandas, numpy, plotly, scipy (see `requirements.txt`)

**Constraints:**
- Budget: Project is developed as an educational/portfolio initiative (no licensing costs)
- Timeline: 4-phase delivery (MySQL → EDA → Power BI → BA Layer)
- Tools: MySQL 8.0+, Python 3.10+, Power BI Desktop only

---

## 9. Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Business Analyst | — | _______________ | Aug 2026 |
| Project Sponsor | — | _______________ | Aug 2026 |
| Data Lead | — | _______________ | Aug 2026 |

---

*Document controlled by: Business Analysis Team · IndoSynth Gramin Bank BI Project*
