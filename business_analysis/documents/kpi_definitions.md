# 📊 KPI Definitions & Governance Dictionary
## IndoSynth Gramin Bank — Business Intelligence Project

> This document is the **official, single source of truth** for all KPIs used across the Power BI dashboard,
> SQL analysis scripts, and the Python KPI tracker. The DAX measure name, SQL formula, threshold, owner,
> and refresh cadence are defined here and must not be changed without updating all three layers.

---

## KPI Governance Principles

1. **One definition per KPI** — no parallel calculations that could produce different numbers
2. **Denominator is always stated** — to prevent division ambiguity
3. **Threshold rationale is documented** — so stakeholders understand WHY a threshold was set
4. **Owner accountability** — each KPI has a named team owner responsible for it

---

## 01. Customer KPIs

### KPI-C1: Total Customers
| Field | Value |
|-------|-------|
| **DAX Measure** | `Total Customers = COUNTROWS(customers)` |
| **SQL Formula** | `SELECT COUNT(*) FROM customers` |
| **Description** | Total number of unique customer accounts in the system |
| **Unit** | Count (#) |
| **Format** | `#,##0` |
| **Threshold** | N/A (informational) |
| **Owner** | Retail Banking Head |
| **Refresh** | Monthly |
| **Dashboard** | V-1.1, V-2.1 |

---

### KPI-C2: Active Customer %
| Field | Value |
|-------|-------|
| **DAX Measure** | `Active Customer % = DIVIDE([Active Customers], [Total Customers], 0) * 100` |
| **SQL Formula** | `SELECT SUM(is_active)/COUNT(*) * 100 FROM customers` |
| **Description** | Percentage of customers with `is_active = TRUE` |
| **Unit** | % |
| **Format** | `0.0%` |
| **🟢 Green (On Track)** | ≥ 85.0% |
| **🟡 Yellow (Watch)** | 75.0% – 84.9% |
| **🔴 Red (Alert)** | < 75.0% |
| **Threshold Rationale** | Industry benchmark for active account rate in rural banks is 80–88% |
| **Owner** | Retail Banking Head |
| **Refresh** | Monthly |

---

### KPI-C3: KYC Verified %
| Field | Value |
|-------|-------|
| **DAX Measure** | `KYC Verified % = DIVIDE(CALCULATE([Total Customers], customers[kyc_status]="Verified"), [Total Customers], 0) * 100` |
| **SQL Formula** | `SELECT SUM(kyc_status='Verified')/COUNT(*) * 100 FROM customers` |
| **Description** | Percentage of customers with verified KYC documentation |
| **Unit** | % |
| **🟢 Green** | ≥ 90.0% |
| **🟡 Yellow** | 80.0% – 89.9% |
| **🔴 Red** | < 80.0% |
| **Threshold Rationale** | RBI mandates 100% KYC compliance; 90% is the operational tracking target |
| **Owner** | Compliance Officer |
| **Refresh** | Weekly |
| **Regulatory Note** | Non-compliance can result in RBI penalties |

---

### KPI-C4: Avg Annual Income (₹ Lakhs)
| Field | Value |
|-------|-------|
| **DAX Measure** | `Avg Annual Income Lakhs = DIVIDE([Avg Annual Income], 100000, 0)` |
| **SQL Formula** | `SELECT AVG(annual_income)/100000 FROM customers` |
| **Description** | Average declared annual income per customer in Indian Lakh Rupees |
| **Unit** | ₹ Lakhs |
| **Threshold** | Informational (used for segment benchmarking) |
| **Owner** | Retail Banking Head |
| **Refresh** | Quarterly |

---

## 02. Loan Portfolio KPIs

### KPI-L1: Approval Rate %
| Field | Value |
|-------|-------|
| **DAX Measure** | `Approval Rate % = DIVIDE([Approved Applications], [Total Applications], 0) * 100` |
| **SQL Formula** | `SELECT SUM(status IN ('Approved','Disbursed'))/COUNT(*) * 100 FROM loan_applications` |
| **Numerator** | Applications with status = 'Approved' OR 'Disbursed' |
| **Denominator** | All loan applications |
| **Unit** | % |
| **🟢 Green** | ≥ 60.0% |
| **🟡 Yellow** | 45.0% – 59.9% |
| **🔴 Red** | < 45.0% |
| **Threshold Rationale** | Industry norm for gramin/rural banks is 55–68%; below 45% suggests overly restrictive policy |
| **Owner** | Head of Credit |
| **Refresh** | Weekly |

---

### KPI-L2: Disbursement Rate %
| Field | Value |
|-------|-------|
| **DAX Measure** | `Disbursement Rate % = DIVIDE([Disbursed Applications], [Total Applications], 0) * 100` |
| **SQL Formula** | `SELECT SUM(status='Disbursed')/COUNT(*) * 100 FROM loan_applications` |
| **Numerator** | Applications with status = 'Disbursed' |
| **Denominator** | All loan applications |
| **Unit** | % |
| **🟢 Green** | ≥ 55.0% |
| **🟡 Yellow** | 40.0% – 54.9% |
| **🔴 Red** | < 40.0% |
| **Threshold Rationale** | Measures full end-to-end conversion; a gap between approval and disbursement indicates process friction |
| **Owner** | Loan Operations |
| **Refresh** | Weekly |

---

### KPI-L3: Total Disbursed Portfolio (₹ Cr)
| Field | Value |
|-------|-------|
| **DAX Measure** | `Total Disbursed Cr = DIVIDE([Total Disbursed Amount], 10000000, 0)` |
| **SQL Formula** | `SELECT SUM(loan_amount_approved)/10000000 FROM loan_applications WHERE status='Disbursed'` |
| **Description** | Total loan amount disbursed expressed in Crore Rupees (1 Cr = 10 million ₹) |
| **Unit** | ₹ Crores |
| **🟢 Green** | ≥ ₹300 Cr |
| **🟡 Yellow** | ₹200 – ₹299 Cr |
| **🔴 Red** | < ₹200 Cr |
| **Owner** | CFO / Business Head |
| **Refresh** | Monthly |

---

## 03. Payment & Risk KPIs

### KPI-R1: Default Rate %
| Field | Value |
|-------|-------|
| **DAX Measure** | `Default Rate % = DIVIDE([Missed Payments Count], [Total EMI Payments], 0) * 100` |
| **SQL Formula** | `SELECT SUM(payment_status='Missed')/COUNT(*) * 100 FROM loan_payments` |
| **Numerator** | EMI rows where `payment_status = 'Missed'` |
| **Denominator** | All EMI payment rows |
| **Unit** | % |
| **🟢 Green** | ≤ 5.0% |
| **🟡 Yellow** | 5.1% – 10.0% |
| **🔴 Red** | > 10.0% |
| **Threshold Rationale** | RBI GNPA (Gross NPA) benchmark for scheduled banks is ~3.9%; 5% is the management alert level for gramin banks |
| **Owner** | Chief Risk Officer |
| **Refresh** | Daily |
| **⚠️ Critical** | This is the most operationally sensitive KPI. Breach triggers immediate credit committee review. |

---

### KPI-R2: On-Time Payment Rate %
| Field | Value |
|-------|-------|
| **DAX Measure** | `On-Time Payment Rate % = DIVIDE([On-Time Payments], [Total EMI Payments], 0) * 100` |
| **SQL Formula** | `SELECT SUM(payment_status='Paid' AND days_late<=0)/COUNT(*) * 100 FROM loan_payments` |
| **Numerator** | EMI rows where `payment_status = 'Paid'` AND `days_late ≤ 0` |
| **Denominator** | All EMI payment rows |
| **Unit** | % |
| **🟢 Green** | ≥ 85.0% |
| **🟡 Yellow** | 75.0% – 84.9% |
| **🔴 Red** | < 75.0% |
| **Threshold Rationale** | A healthy rural bank maintains 85–92% on-time collection rate; below 75% signals systemic repayment stress |
| **Owner** | Collections Team |
| **Refresh** | Daily |

---

### KPI-R3: Total Outstanding Balance (₹ Cr)
| Field | Value |
|-------|-------|
| **DAX Measure** | `Total Outstanding Balance Cr = DIVIDE(SUM(loan_payments[outstanding_balance]), 10000000, 0)` |
| **SQL Formula** | `SELECT SUM(outstanding_balance)/10000000 FROM loan_payments` |
| **Description** | Total principal balance yet to be repaid across all active loans |
| **Unit** | ₹ Crores |
| **Threshold** | Monitored relative to Total Disbursed portfolio (Outstanding/Disbursed ratio expected < 60% at maturity) |
| **Owner** | Finance / Treasury |
| **Refresh** | Monthly |

---

## 04. Transaction / Digital KPIs

### KPI-T1: UPI Adoption Share %
| Field | Value |
|-------|-------|
| **DAX Measure** | `UPI Adoption Share % = DIVIDE([UPI Transactions Count], [Total Transactions], 0) * 100` |
| **SQL Formula** | `SELECT SUM(transaction_mode='UPI')/COUNT(*) * 100 FROM transactions` |
| **Numerator** | Transactions where `transaction_mode = 'UPI'` |
| **Denominator** | All transactions |
| **Unit** | % |
| **🟢 Green** | ≥ 60.0% |
| **🟡 Yellow** | 40.0% – 59.9% |
| **🔴 Red** | < 40.0% |
| **Threshold Rationale** | NPCI reports national UPI share at 65%+ in 2024–25; rural banks should target ≥60% |
| **Owner** | Digital Banking Head |
| **Refresh** | Monthly |

---

### KPI-T2: Transaction Success Rate %
| Field | Value |
|-------|-------|
| **DAX Measure** | `Success Rate % = DIVIDE(CALCULATE([Total Transactions], transactions[status]="Success"), [Total Transactions], 0) * 100` |
| **SQL Formula** | `SELECT SUM(status='Success')/COUNT(*) * 100 FROM transactions` |
| **Unit** | % |
| **🟢 Green** | ≥ 97.0% |
| **🟡 Yellow** | 92.0% – 96.9% |
| **🔴 Red** | < 92.0% |
| **Threshold Rationale** | NPCI SLA mandates >99% success rate for UPI; 97% covers all channels including offline |
| **Owner** | Technology Operations |
| **Refresh** | Daily |

---

## KPI Threshold Summary Table

| KPI | Green | Yellow | Red | Direction | Owner |
|-----|-------|--------|-----|-----------|-------|
| Active Customer % | ≥ 85% | 75–84% | < 75% | ↑ Higher Better | Retail Banking |
| KYC Verified % | ≥ 90% | 80–89% | < 80% | ↑ Higher Better | Compliance |
| Approval Rate % | ≥ 60% | 45–59% | < 45% | ↑ Higher Better | Credit |
| Disbursement Rate % | ≥ 55% | 40–54% | < 40% | ↑ Higher Better | Loan Ops |
| Default Rate % | ≤ 5% | 5–10% | > 10% | ↓ Lower Better | Risk |
| On-Time Payment Rate % | ≥ 85% | 75–84% | < 75% | ↑ Higher Better | Collections |
| UPI Adoption Share % | ≥ 60% | 40–59% | < 40% | ↑ Higher Better | Digital |
| Transaction Success Rate % | ≥ 97% | 92–96% | < 92% | ↑ Higher Better | Tech Ops |

---

*Document Owner: Business Analyst — IndoSynth Gramin Bank BI Project*
*Last Reviewed: August 2026 | Next Review: February 2027*
