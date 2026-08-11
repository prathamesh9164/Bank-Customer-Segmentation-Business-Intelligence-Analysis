# 📄 Executive Summary — Data Analytics Findings
## IndoSynth Gramin Bank | Business Analyst Report | August 2026

> **Audience**: MD, CFO, Chief Risk Officer, Zonal Heads
> **Classification**: Internal — Management Use Only
> **Period**: FY 2018–2025 (7-Year Analysis)

---

## 🔑 At a Glance: 5 Headline Findings

| # | Finding | Business Impact |
|---|---------|----------------|
| 1 | **64.2% loan approval rate** — but 31.5% of applications rejected, many due to fixable reasons | ₹150+ Cr in lost disbursements annually from avoidable rejections |
| 2 | **UPI grew from <15% in 2018 to >65% in 2025** | ₹200+ Cr shift from cash to digital reduces branch operational cost by est. 12% |
| 3 | **Default rate sits at 4.8%** — within the 5% threshold but only 0.2pp of margin | 2,400+ customers in the critical risk zone; one macro shock could breach NPA limits |
| 4 | **Rural branches disburse 66% of total portfolio** but process loans 40% slower | Urban branch processing speed benchmark can be transferred to rural via officer training |
| 5 | **Top 3 rejection reasons are addressable** (Low Credit Score, Insufficient Income, Document Gaps) | Targeted financial literacy + pre-loan counseling could recover 8–12% of rejected applications |

---

## 1. Portfolio Overview

IndoSynth Gramin Bank has built a substantial lending portfolio over 7 years:

- **₹389.3 Cr** in active disbursed loans across 300,000 applications
- **100,000 customers** served, 88.5% actively transacting
- **250 branches** across 5 zones (North, South, East, West, Central)
- **₹1,425+ Cr** in annual transaction volume (debit + credit flows)

The data validates that IndoSynth is operating at the scale of a mid-tier gramin bank with strong growth fundamentals. The challenge is **translating scale into efficiency and reducing risk concentration**.

---

## 2. Customer Base — Strengths & Gaps

### Strengths ✅
- **92.1% KYC compliance** — well above the regulatory watch level of 80%
- **88.5% active customer rate** — indicates healthy account engagement
- Strong presence in agriculture-heavy states (likely Uttar Pradesh, Maharashtra, Madhya Pradesh based on zone distribution)

### Gaps ⚠️
- **12,420 customers (12.4%)** have credit scores below 600 — classified as high risk
- The **₹3–6 LPA income band** (Middle income) shows the highest loan demand but mid-tier repayment quality
- Premium segment (₹12+ LPA) is underserved — only 8% of loan volume despite contributing 22% of interest income

### Recommendation
> Launch a **Premium Customer Acquisition Program** targeting the top income decile.
> Introduce salary-linked pre-approved personal loans to capture high-LTV, low-risk customers.

---

## 3. Loan Performance — The Funnel Leakage Problem

The application-to-disbursement pipeline has significant drop-off:

```
Applications   →   Under Review   →   Approved   →   Disbursed
  300,000           186,000           192,600         192,600*
    100%              62%               64.2%           ~62%
               ↓ 38% lost         ↓ Mostly admin      ↓ Process gap
```

> [!IMPORTANT]
> **The biggest drop-off is at the Under Review stage** — 38% of applications never even reach the
> credit review desk. This suggests a front-end filtering problem, not a credit quality problem.

The top 3 rejection reasons (Pareto analysis) account for ~78% of all rejections:

1. **Low Credit Score** (< 600) — 34% of rejections
2. **Insufficient Income** — 28% of rejections
3. **Incomplete Documentation** — 16% of rejections

### Recommendation
> Introduce a **Pre-Screening Self-Assessment Tool** at branches where applicants can check
> their eligibility before formal submission. This will reduce wasted processing effort by
> an estimated 15–20% and improve the experience for borderline applicants.

---

## 4. Risk Profile — Close to the Edge

The bank's **default rate of 4.8%** is within the 5.0% management threshold but leaves very little buffer.

**Risk Concentration Analysis reveals:**
- **North Zone** has a 22% higher default rate than the bank average — driven by 3 underperforming branches
- **Education Loans** have the highest NPA rate (est. 8.2%) due to extended moratorium periods
- **Below-600 credit score customers** account for only 12% of loan volume but 41% of all missed payments

> [!CAUTION]
> If macroeconomic conditions worsen (crop failure, interest rate hike), the bank could breach the 5% 
> NPA threshold within 2 quarters without immediate intervention.

### 3 Risk Mitigation Actions (Priority Order)

| Priority | Action | Expected Impact | Timeline |
|----------|--------|-----------------|----------|
| 🔴 P1 | Credit score floor: Mandate minimum 600 score for Education Loans without collateral | Reduce Education Loan NPA by est. 30% | Immediate |
| 🟠 P2 | North Zone intensive: Assign risk officers to the 3 highest-default branches | Stabilize North Zone default rate within 6 months | 30 days |
| 🟡 P3 | Automated EMI reminder system via UPI/SMS 7 days before due date | Improve on-time rate by est. 3–5pp | 90 days |

---

## 5. Digital Transformation — A Success Story Worth Amplifying

The **UPI adoption trajectory is the strongest performance narrative** in this dataset:

| Year | UPI Share | Traditional Share |
|------|-----------|------------------|
| 2018 | < 15% | > 70% |
| 2021 | ~38% | ~45% |
| 2025 | > 65% | < 20% |

This is above the national rural banking average and demonstrates successful digital onboarding of a traditionally cash-dependent rural customer base.

**Additional insight**: Customers in the **Heavy UPI tier (>80% UPI transactions)** show a **2.1pp lower default rate** than customers using no digital channels — suggesting digital engagement is a proxy for financial discipline.

### Recommendation
> **UPI-Linked Loan Products**: Launch a micro-loan product (₹10,000 – ₹50,000) that requires
> active UPI usage as eligibility. This simultaneously grows the digital portfolio and
> self-selects for lower-risk borrowers.

---

## 6. Branch Operations — Efficiency Inequality

The 250 branches show wide performance variance:

- **Top 10 branches** generate 38% of total disbursed volume with only 4% of defaults
- **Bottom 20 branches** contribute 6% of volume but 14% of defaults
- **Rural branches** are 40% slower to process loans (avg 22 days vs 13 days for Urban)

> [!TIP]
> The processing speed gap between Rural and Urban is primarily driven by **documentation
> collection delays**, not credit decision time. A **Digital Document Upload Portal**
> for rural customers could close this gap by 60–70%.

---

## 7. Strategic Recommendations Summary

| Area | Quick Win (< 30 days) | Medium Term (3–6 months) | Strategic (6–18 months) |
|------|----------------------|--------------------------|------------------------|
| **Risk** | Flag top 100 high-risk borrowers for CRM follow-up | Introduce credit score floor policies by loan type | AI-based early warning scoring model |
| **Loans** | Deploy pre-screening eligibility checker at branches | Train officers on documentation collection efficiency | Straight-through processing (STP) for low-risk applications |
| **Digital** | Set UPI adoption target per branch (branch-level KPI) | Launch UPI-linked micro-loan product | Full digital loan journey (application to disbursement) |
| **Customers** | Identify and call top 500 Premium segment customers | Design segment-specific product bundles | Customer 360° CRM integration |
| **Branches** | Share top-branch best practices via internal playbook | Officer retraining program for North Zone | Performance-linked officer incentive scheme |

---

## 8. Conclusion

IndoSynth Gramin Bank is at an **inflection point**. The data tells a story of a bank with:
- **Strong fundamentals** — large customer base, growing digital adoption, within-threshold risk levels
- **Significant operational inefficiency** — funnel leakage, processing speed gaps, geographic risk concentration
- **Untapped potential** — Premium segment underserved, digital success not yet converted into product strategy

The **Power BI dashboard** delivers visibility. The **SQL analyses** provide diagnostic depth. The next step is **action** — using these insights to prioritize the 3 Quick Wins above, which together could generate an estimated **₹25–40 Cr in additional annual disbursements** and reduce NPA exposure by **0.8–1.2 percentage points** within 12 months.

---

*Prepared by: Business Analyst — Data & BI Team*
*Data Source: 9 core banking tables · 2.9M+ records · FY 2018–2025*
*Analytical Tools: MySQL 8.0 · Python (pandas, plotly) · Power BI Desktop*
*Next Scheduled Review: November 2026 (Q3 Update)*
