# 👥 Stakeholder Analysis Document
## IndoSynth Gramin Bank — Data Analytics & BI Project

| Field | Detail |
|-------|--------|
| **Document Version** | v1.0 |
| **Prepared By** | Business Analyst — Data & BI Team |
| **Date** | August 2026 |
| **Status** | Approved |
| **Project Code** | IGB-BI-2026 |

> **Purpose**: This document identifies, classifies, and defines the engagement strategy for all stakeholders
> involved in or affected by the IndoSynth Gramin Bank Data Analytics & BI initiative.
> It ensures that the right information reaches the right people at the right time throughout the project lifecycle.

---

## 1. Stakeholder Identification Summary

A total of **13 distinct stakeholder groups** have been identified across 4 organizational tiers:

| Tier | Category | Count | Engagement Level |
|------|----------|------:|-----------------|
| **Tier 1** | Executive Leadership | 3 | Quarterly steering, final approval authority |
| **Tier 2** | Functional Heads (Department) | 5 | Monthly review, primary report consumers |
| **Tier 3** | Operational Users | 3 | Weekly / daily dashboard users |
| **Tier 4** | Technical & Support | 2 | Continuous project implementation partners |

---

## 2. Stakeholder Register

### 2.1 Tier 1 — Executive Leadership

| ID | Stakeholder | Title | Department | Influence | Interest | Quadrant |
|----|-------------|-------|------------|:---------:|:--------:|----------|
| S-01 | MD / CEO | Managing Director & CEO | Executive Office | 🔴 High | 🔴 High | **Manage Closely** |
| S-02 | CFO / Finance Head | Chief Financial Officer | Finance & Accounts | 🔴 High | 🟡 Medium | **Keep Satisfied** |
| S-03 | Chief Risk Officer | Head of Risk & Compliance | Risk Management | 🔴 High | 🔴 High | **Manage Closely** |

### 2.2 Tier 2 — Functional Heads

| ID | Stakeholder | Title | Department | Influence | Interest | Quadrant |
|----|-------------|-------|------------|:---------:|:--------:|----------|
| S-04 | Head of Retail Banking | VP / Head — Retail Banking | Retail Banking | 🟡 Medium | 🔴 High | **Keep Informed** |
| S-05 | Head of Credit | VP / Head — Credit & Underwriting | Credit Division | 🟡 Medium | 🔴 High | **Keep Informed** |
| S-06 | Head of Digital Banking | VP / Head — Digital & Payments | Digital Banking | 🟡 Medium | 🔴 High | **Keep Informed** |
| S-07 | Head of Operations | VP — Branch Operations | Operations | 🟡 Medium | 🟡 Medium | **Monitor** |
| S-08 | Compliance Officer | Head — Regulatory Compliance | Compliance & Audit | 🔴 High | 🟡 Medium | **Keep Satisfied** |

### 2.3 Tier 3 — Operational Users

| ID | Stakeholder | Title | Department | Influence | Interest | Quadrant |
|----|-------------|-------|------------|:---------:|:--------:|----------|
| S-09 | Zonal Managers (5) | Regional Business Managers | Operations / Zonal | 🟡 Medium | 🔴 High | **Keep Informed** |
| S-10 | Branch Managers (250) | Branch Head / Branch Manager | Branch Network | 🟢 Low | 🔴 High | **Keep Informed** |
| S-11 | Loan Officers / RMs | Relationship Manager | Credit / Retail | 🟢 Low | 🟡 Medium | **Monitor** |

### 2.4 Tier 4 — Technical & Support

| ID | Stakeholder | Title | Department | Influence | Interest | Quadrant |
|----|-------------|-------|------------|:---------:|:--------:|----------|
| S-12 | IT / Database Team | DBA + Infrastructure Engineer | Information Technology | 🟡 Medium | 🔴 High | **Keep Informed** |
| S-13 | Business Analyst (Project Lead) | Senior Business Analyst | Data & Analytics | 🔴 High | 🔴 High | **Manage Closely** |

---

## 3. Stakeholder Power-Interest Grid

```
                     POWER / INFLUENCE
            Low                         High
         ┌──────────────────┬──────────────────┐
High     │                  │                  │
         │  KEEP INFORMED   │  MANAGE CLOSELY  │
INTEREST │                  │                  │
         │  S-04, S-05,     │  S-01, S-03,     │
         │  S-06, S-09,     │  S-13            │
         │  S-10, S-12      │                  │
         ├──────────────────┼──────────────────┤
Low      │                  │                  │
         │    MONITOR       │  KEEP SATISFIED  │
         │                  │                  │
         │  S-07, S-11      │  S-02, S-08      │
         │                  │                  │
         └──────────────────┴──────────────────┘
```

| Quadrant | Strategy |
|----------|----------|
| **Manage Closely** | Full engagement — involve in all key decisions, provide deep-dive analysis, seek sign-off |
| **Keep Satisfied** | Regular high-level updates, escalate risks proactively, avoid surprises |
| **Keep Informed** | Share relevant outputs and dashboards, collect feedback on usability |
| **Monitor** | Minimal active engagement; track any shift in interest or influence levels |

---

## 4. Detailed Stakeholder Profiles

### S-01 — MD / CEO

| Field | Detail |
|-------|--------|
| **Name / Role** | Managing Director & Chief Executive Officer |
| **Primary Goal** | Bank-wide growth, portfolio health, regulatory standing, and shareholder returns |
| **Pain Points** | Lack of real-time, consolidated view of bank performance across 250 branches |
| **Project Expectations** | Single-page executive dashboard showing portfolio health, NPA status, and growth KPIs |
| **Success Metric** | Can answer "Is the bank on track?" in under 60 seconds from the dashboard |
| **Dashboard Pages** | Page 1 (Executive Overview) |
| **Preferred Communication** | Monthly Steering Committee meeting + automated weekly KPI email digest |
| **Risk of Non-Engagement** | Project de-prioritized, budget reallocated |
| **Key Concern** | NPA rate breaching 5.0% regulatory threshold |

---

### S-02 — CFO / Finance Head

| Field | Detail |
|-------|--------|
| **Name / Role** | Chief Financial Officer |
| **Primary Goal** | Revenue maximization, interest income tracking, cost of risk management |
| **Pain Points** | Weekly Excel-based reports are stale by the time they reach Finance; no drill-down capability |
| **Project Expectations** | Disbursement portfolio value, interest income trends, outstanding balance, and penalty collections |
| **Success Metric** | Elimination of manual weekly reporting; automated Power BI refresh |
| **Dashboard Pages** | Page 1 (Executive Overview), Page 3 (Loan Performance) |
| **Preferred Communication** | Monthly Finance Review + on-demand dashboard access |
| **Risk of Non-Engagement** | Resistance to changing existing reporting workflows |
| **Key Concern** | Data accuracy — CFO will validate Power BI numbers against core banking system |

---

### S-03 — Chief Risk Officer (CRO)

| Field | Detail |
|-------|--------|
| **Name / Role** | Chief Risk Officer |
| **Primary Goal** | NPA containment, credit risk profiling, early warning signals for defaults |
| **Pain Points** | No proactive alert system; defaults are identified only after 90+ days overdue |
| **Project Expectations** | Real-time default rate, days-late distribution, risk-tier breakdown by branch and zone |
| **Success Metric** | Can identify the top 10 highest-risk branches in under 2 minutes |
| **Dashboard Pages** | Page 4 (Payment Behavior & Risk Monitoring) |
| **Preferred Communication** | Weekly Risk Committee briefing + daily dashboard monitoring |
| **Risk of Non-Engagement** | Incomplete risk KPI definitions; dashboard missing critical risk dimensions |
| **Key Concern** | Education Loan NPA (est. 8.2%) — wants drill-down by loan type and zone |

---

### S-04 — Head of Retail Banking

| Field | Detail |
|-------|--------|
| **Name / Role** | VP / Head — Retail Banking |
| **Primary Goal** | Customer base growth, segment profitability, KYC compliance rates |
| **Pain Points** | No visibility into which customer segments are churning or underperforming |
| **Project Expectations** | Customer demographics breakdown, segment-wise product holding, income distribution |
| **Success Metric** | Can target the correct customer segment for new product campaigns using dashboard data |
| **Dashboard Pages** | Page 2 (Customer Demographics) |
| **Preferred Communication** | Monthly Business Review |
| **Key Concern** | Premium segment (₹12+ LPA) is underserved; wants visibility into this cohort |

---

### S-05 — Head of Credit

| Field | Detail |
|-------|--------|
| **Name / Role** | VP / Head — Credit & Underwriting |
| **Primary Goal** | Loan approval efficiency, reduction of avoidable rejections, disbursement throughput |
| **Pain Points** | No Pareto analysis of rejection reasons; credit policy set without data backing |
| **Project Expectations** | Application funnel, rejection reason breakdown, approval rate by credit band, loan officer performance |
| **Success Metric** | Identifies the top 3 addressable rejection reasons and initiates a policy change within 60 days |
| **Dashboard Pages** | Page 3 (Loan Performance & Portfolio Analytics) |
| **Preferred Communication** | Bi-weekly Credit Review |
| **Key Concern** | Funnel drop-off at the Under Review stage (38% of applications) |

---

### S-06 — Head of Digital Banking

| Field | Detail |
|-------|--------|
| **Name / Role** | VP / Head — Digital Banking & Payments |
| **Primary Goal** | UPI adoption growth, digital transaction volumes, digital-first product strategy |
| **Pain Points** | UPI growth is known qualitatively but not quantified with trend data by branch/zone |
| **Project Expectations** | Year-on-year UPI share trend, UPI vs. traditional split, category-wise transaction analysis |
| **Success Metric** | UPI adoption share visible by zone, enabling targeted digital push in lagging branches |
| **Dashboard Pages** | Page 5 (Transaction & Digital Channel Intelligence) |
| **Preferred Communication** | Monthly Digital Strategy Meeting |
| **Key Concern** | Branches with < 40% UPI adoption need identification for targeted digital literacy programs |

---

### S-07 — Head of Operations

| Field | Detail |
|-------|--------|
| **Name / Role** | VP — Branch Operations |
| **Primary Goal** | Branch network efficiency, processing speed, staff productivity |
| **Pain Points** | No standardized benchmark for processing time across branch types (Rural vs. Urban) |
| **Project Expectations** | Branch performance metrics, loan processing timelines, officer workload distribution |
| **Success Metric** | Branch efficiency benchmarks visible; identifies the performance gap between Rural and Urban |
| **Dashboard Pages** | Page 6 (Branch Operations) |
| **Preferred Communication** | Monthly Operations Review |
| **Key Concern** | Rural branches are 40% slower — needs root cause data to act |

---

### S-08 — Compliance Officer

| Field | Detail |
|-------|--------|
| **Name / Role** | Head — Regulatory Compliance & Audit |
| **Primary Goal** | RBI regulatory compliance, KYC verification, data completeness |
| **Pain Points** | KYC status tracked manually; no automated flag for non-compliant accounts |
| **Project Expectations** | KYC Verified % KPI, active vs. inactive customer ratios, data completeness metrics |
| **Success Metric** | KYC dashboard visible with drilldown to identify non-verified accounts by branch |
| **Dashboard Pages** | Page 2 (Customer Demographics) |
| **Preferred Communication** | Monthly Compliance Report; immediate escalation on KYC breach |
| **Key Concern** | RBI mandates approaching — KYC % below 80% triggers regulatory action |
| **Regulatory Note** | Must be notified immediately if KYC Verified % drops below the 🔴 threshold |

---

### S-09 — Zonal Managers (5 Zones)

| Field | Detail |
|-------|--------|
| **Name / Role** | Regional Business Managers — North, South, East, West, Central |
| **Primary Goal** | Meet zone-level disbursement, collection, and customer acquisition targets |
| **Pain Points** | No zone-vs-zone benchmarking; managers rely on ad-hoc Excel files from branches |
| **Project Expectations** | Zone-filtered dashboards; zone-wise disbursement sunburst; default rate by zone |
| **Success Metric** | Can independently navigate the dashboard and extract zone KPIs without BA support |
| **Dashboard Pages** | All pages (filtered to their zone via slicer) |
| **Preferred Communication** | Monthly Zonal Review Meeting |
| **Training Needed** | 1-hour Power BI navigation training + quick reference card |

---

### S-10 — Branch Managers (250 Branches)

| Field | Detail |
|-------|--------|
| **Name / Role** | Branch Head / Branch Manager |
| **Primary Goal** | Branch targets — loan disbursements, EMI collections, new customer onboarding |
| **Pain Points** | No self-serve visibility into branch performance vs. peers; rely on Zonal Managers for data |
| **Project Expectations** | Branch-level KPIs (disbursement, default rate, UPI share) filterable by branch |
| **Success Metric** | Branch Manager can check their branch's status independently on a daily basis |
| **Dashboard Pages** | Page 6 (Branch Operations) — filtered to their branch |
| **Preferred Communication** | Weekly branch performance email report (auto-generated from Power BI) |
| **Training Needed** | 30-minute Power BI viewer onboarding; branch-specific user guide |
| **Key Concern** | Fear of performance being visible to senior leadership — needs cultural change management |

---

### S-11 — Loan Officers / Relationship Managers

| Field | Detail |
|-------|--------|
| **Name / Role** | Relationship Manager / Loan Processing Officers |
| **Primary Goal** | Process loan applications accurately and efficiently; minimize rejections |
| **Pain Points** | No feedback loop on why their applications are rejected upstream |
| **Project Expectations** | Individual officer performance (bubble chart — applications processed vs. approval rate) |
| **Success Metric** | Loan officers see their own performance metrics and identify improvement areas |
| **Dashboard Pages** | Page 3 (Loan Performance) — officer bubble chart |
| **Preferred Communication** | Shared by Branch Manager in team meetings |
| **Key Concern** | Privacy concern — individual performance visibility may cause anxiety without proper framing |

---

### S-12 — IT / Database Team

| Field | Detail |
|-------|--------|
| **Name / Role** | Database Administrator + Infrastructure Engineers |
| **Primary Goal** | Stable data pipeline, scheduled refresh, performance optimization |
| **Pain Points** | Legacy systems not integrated; manual CSV exports are error-prone |
| **Project Expectations** | Clear documentation of MySQL schema, Python preprocessing steps, and Power BI data model |
| **Success Metric** | Can reproduce the full pipeline from scratch using provided documentation within 4 hours |
| **Dashboard Pages** | All (technical perspective — data freshness, load times) |
| **Preferred Communication** | Technical handover documentation + bi-weekly sync during build phase |
| **Deliverable** | MySQL schema diagram, `requirements.txt`, Power BI data model documentation |

---

### S-13 — Business Analyst (Project Lead)

| Field | Detail |
|-------|--------|
| **Name / Role** | Senior Business Analyst — Data & BI Team |
| **Primary Goal** | Deliver the 3-phase analytics solution on time, within scope, and to stakeholder satisfaction |
| **Pain Points** | Changing requirements mid-project; stakeholders unfamiliar with data-driven decision-making |
| **Project Expectations** | Clearly scoped requirements, stakeholder buy-in, documented handover |
| **Success Metric** | All 13 stakeholder groups are using the dashboard within 30 days of go-live |
| **Dashboard Pages** | All (oversight role) |
| **Preferred Communication** | Project status updates to Steering Committee (S-01, S-02, S-03) every 2 weeks |

---

## 5. RACI Matrix

The RACI matrix defines responsibility across the 4 project phases for each stakeholder group.

> **R** = Responsible (does the work) | **A** = Accountable (owns the outcome) | **C** = Consulted (provides input) | **I** = Informed (receives updates)

| Activity | S-01 CEO | S-02 CFO | S-03 CRO | S-04 Retail | S-05 Credit | S-06 Digital | S-07 Ops | S-08 Compliance | S-09 Zonal | S-10 Branch | S-12 IT | S-13 BA |
|----------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Project Kick-off & Scope Approval** | A | C | C | I | I | I | I | I | — | — | I | R |
| **Business Requirements Gathering** | I | C | C | C | C | C | C | C | I | — | I | R |
| **MySQL Schema Design** | — | — | — | — | — | — | — | — | — | — | C | R |
| **Data Bulk Load & Validation** | — | — | — | — | — | — | — | — | — | — | R | A |
| **EDA & Preprocessing** | — | — | — | — | — | — | — | — | — | — | I | R |
| **KPI Definition & Threshold Setting** | C | A | C | C | C | C | — | C | — | — | — | R |
| **Power BI Dashboard Build** | — | — | — | — | — | — | — | — | — | — | C | R |
| **Dashboard UAT (User Acceptance)** | I | C | R | R | R | R | C | C | I | — | C | A |
| **Stakeholder Training & Onboarding** | I | I | I | C | C | C | C | I | R | R | I | A |
| **Go-Live Approval** | A | C | C | I | I | I | I | C | I | I | C | R |
| **Post-Launch Dashboard Monitoring** | I | I | R | R | R | R | C | C | R | R | R | A |
| **Quarterly Performance Review** | A | C | C | C | C | C | C | C | I | I | I | R |

---

## 6. Stakeholder Needs vs. Dashboard Mapping

| Stakeholder | Primary Business Question | Dashboard Page | Key Visual |
|-------------|--------------------------|---------------|-----------|
| S-01 (CEO) | Is the bank healthy at a portfolio level? | Executive Overview (P1) | KPI Card Matrix — Portfolio, NPA, Approval Rate, UPI Share |
| S-02 (CFO) | What is our disbursed portfolio value and interest income trend? | Executive Overview (P1), Loan Performance (P3) | Total Disbursed ₹Cr, Monthly Loan Trend |
| S-03 (CRO) | Where are the default hotspots and how close are we to the NPA threshold? | Payment Behavior & Risk (P4) | Default Rate by Credit Band, Days-Late Heatmap |
| S-04 (Retail Head) | Who are our customers and which segments are growing? | Customer Demographics (P2) | Age Histogram, Segment Donut, Income Boxplot |
| S-05 (Credit Head) | Why are loans being rejected and where is the funnel leaking? | Loan Performance (P3) | Rejection Reasons Bar, Approval Rate by Credit Band |
| S-06 (Digital Head) | How fast is UPI growing and which branches are lagging? | Transaction & Digital (P5) | 100% Stacked Bar — UPI vs Traditional (2018–2025) |
| S-07 (Ops Head) | Which branches are most efficient and where is processing slowest? | Branch Operations (P6) | Branch Processing Speed, Officer Performance Bubble |
| S-08 (Compliance) | What percentage of customers are KYC verified? | Customer Demographics (P2) | KYC Verified % KPI Card |
| S-09 (Zonal Mgrs) | How is my zone performing vs. the other 4 zones? | All pages (zone filter) | Zone-wise Disbursement Sunburst, Zone Default Rate |
| S-10 (Branch Mgrs) | How does my branch rank against peers in my zone? | Branch Operations (P6) | Branch Rank Table, Disbursement vs. Default Scatter |
| S-11 (Loan Officers) | How does my application volume and approval rate compare to my team? | Loan Performance (P3) | Officer Performance Bubble Chart |
| S-12 (IT Team) | Is the data pipeline running correctly and is the data fresh? | All pages (data freshness) | Last Refresh timestamp, Row Count validation |

---

## 7. Communication Plan

### 7.1 Communication Schedule

| # | Communication Type | Audience | Frequency | Format | Owner |
|---|-------------------|----------|-----------|--------|-------|
| 1 | **Steering Committee Briefing** | S-01, S-02, S-03 | Fortnightly (during build), Monthly (post-launch) | PowerPoint summary + live dashboard demo | S-13 (BA) |
| 2 | **Executive KPI Dashboard Email** | S-01, S-02 | Weekly (auto-generated) | Power BI subscriptions email with PDF snapshot | S-12 (IT) |
| 3 | **Functional Head Monthly Review** | S-04, S-05, S-06, S-07, S-08 | Monthly | Power BI dashboard walkthrough + discussion | S-13 (BA) |
| 4 | **Zonal Performance Pack** | S-09 (5 Zonal Managers) | Monthly | Filtered Power BI export (per zone) | S-13 (BA) |
| 5 | **Branch Performance Report** | S-10 (250 Branch Managers) | Weekly | Automated Power BI email subscription (branch filtered) | S-12 (IT) |
| 6 | **Risk Alert Notification** | S-03, S-08 | As-triggered (threshold breach) | Email alert when Default Rate % > 5.0% or KYC % < 80% | S-12 (IT) |
| 7 | **Technical Sync** | S-12, S-13 | Bi-weekly during build, Monthly post-launch | Internal team call | S-13 (BA) |
| 8 | **Project Status Report** | All stakeholders | Monthly | 1-page project status document | S-13 (BA) |

### 7.2 Escalation Path

```
Issue Raised by Any Stakeholder
         │
         ▼
    S-13 Business Analyst  ──► Resolves within 3 business days
         │
         │ (if unresolved or high-impact)
         ▼
    S-07 Head of Operations / Functional Head  ──► Resolves within 5 business days
         │
         │ (if strategic or budget-related)
         ▼
    S-01 MD / CEO (Steering Committee)  ──► Final decision within 10 business days
```

---

## 8. Engagement Strategy by Quadrant

### 8.1 Manage Closely — S-01, S-03, S-13

| Strategy | Action |
|----------|--------|
| **Involve in key decisions** | Invite to KPI threshold review sessions and UAT sign-off |
| **Proactive risk reporting** | Notify immediately of any scope, timeline, or data quality risk |
| **Regular 1-on-1 touchpoints** | Fortnightly steering meeting with agenda shared 48 hours in advance |
| **Deliverable previews** | Share dashboard wireframes and prototypes before final build |

### 8.2 Keep Satisfied — S-02, S-08

| Strategy | Action |
|----------|--------|
| **High-level summaries** | No deep technical detail; communicate in business outcomes and ₹ impact |
| **No surprises** | Proactively share any data quality findings that could affect financial numbers |
| **Regulatory alignment** | Ensure all KPI thresholds are cross-referenced with RBI guidelines before sign-off |
| **Formal approvals** | Seek formal sign-off on KPI definitions document before dashboard build |

### 8.3 Keep Informed — S-04, S-05, S-06, S-09, S-10, S-12

| Strategy | Action |
|----------|--------|
| **Monthly functional reviews** | Walkthrough of dashboard relevant to their domain |
| **UAT participation** | Involve in user acceptance testing for their specific dashboard pages |
| **Training delivery** | Provide role-specific training (Power BI viewer for end users, model deep-dive for IT) |
| **Feedback loops** | Post-launch survey at 30 days and 90 days to capture usability feedback |

### 8.4 Monitor — S-07, S-11

| Strategy | Action |
|----------|--------|
| **Periodic check-ins** | Include in monthly project status email; review if their interest/influence shifts |
| **Indirect engagement** | Reach through their functional head (S-05 for S-11, S-07 already monitored) |
| **Sensitivity management** | For S-11 (Loan Officers), ensure individual performance data is framed constructively |

---

## 9. Stakeholder Risk Register

| Risk ID | Stakeholder | Risk Description | Likelihood | Impact | Mitigation |
|---------|-------------|-----------------|:----------:|:------:|-----------|
| SR-01 | S-01 (CEO) | Executive sponsor deprioritizes project due to operational demands | 🟡 Medium | 🔴 High | Fortnightly steering meetings to maintain visibility; link project to bank's strategic KPIs |
| SR-02 | S-02 (CFO) | CFO challenges data accuracy vs. core banking system numbers | 🟡 Medium | 🔴 High | Pre-launch reconciliation workshop; document any known data source differences |
| SR-03 | S-03 (CRO) | CRO demands real-time data (out of scope) | 🟢 Low | 🟡 Medium | Clearly document batch refresh schedule in scope documentation; offer daily refresh as compromise |
| SR-04 | S-05 (Credit Head) | Resistance to changing loan approval policies based on data | 🔴 High | 🟡 Medium | Frame insights as "opportunities" not "problems"; involve Credit Head in hypothesis testing review |
| SR-05 | S-10 (Branch Managers) | Low adoption of dashboard due to fear of performance visibility | 🔴 High | 🟡 Medium | Cultural change messaging from S-01/S-07; frame dashboard as support tool, not surveillance |
| SR-06 | S-11 (Loan Officers) | Privacy/anxiety concerns about individual performance tracking | 🟡 Medium | 🟢 Low | Anonymize officer names in shared views; individual data accessible only to direct manager |
| SR-07 | S-12 (IT Team) | Delays in MySQL setup or data refresh configuration | 🟡 Medium | 🔴 High | Buffer 2 weeks in project plan for IT environment setup; detailed technical documentation |
| SR-08 | S-08 (Compliance) | KYC data found to be below threshold during EDA — creates regulatory risk | 🟡 Medium | 🔴 High | Immediate escalation to S-08 and S-01 if KYC % < 80% found in data; not delayed until go-live |

---

## 10. Stakeholder Sign-Off Requirements

The following sign-offs are required at key project milestones:

| Milestone | Required Sign-Off | Stakeholder(s) | Target Date |
|-----------|------------------|----------------|-------------|
| Business Requirements Approved | Formal document sign-off | S-01, S-03, S-13 | Aug 2026 |
| KPI Definitions Locked | Review and approval of `kpi_definitions.md` | S-02, S-03, S-05 | Aug 2026 |
| MySQL Schema Validated | Technical review and data quality sign-off | S-12, S-13 | Aug 2026 |
| Dashboard UAT Complete | User acceptance sign-off per page | S-04, S-05, S-06, S-07 | Sep 2026 |
| Go-Live Approval | Final project go-live authorization | S-01, S-13 | Sep 2026 |
| Post-Launch Review (30 days) | Feedback and issue resolution sign-off | S-01, S-03, S-13 | Oct 2026 |

---

## 11. Glossary

| Term | Definition |
|------|-----------|
| **RACI** | Responsibility Assignment Matrix: Responsible, Accountable, Consulted, Informed |
| **NPA** | Non-Performing Asset — a loan where principal or interest has not been paid for 90+ days |
| **KYC** | Know Your Customer — mandatory RBI identity verification for all bank account holders |
| **UAT** | User Acceptance Testing — end-user validation of the dashboard before go-live |
| **Power-Interest Grid** | A 2×2 stakeholder classification framework based on influence and interest levels |
| **BA** | Business Analyst — the project lead responsible for requirements, design, and delivery coordination |
| **Gramin Bank** | A rural cooperative bank focused on serving agricultural and semi-urban communities in India |

---

## 12. Document Control & Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Business Analyst (Author) | — | _______________ | Aug 2026 |
| Project Sponsor (MD/CEO) | — | _______________ | Aug 2026 |
| Chief Risk Officer | — | _______________ | Aug 2026 |
| Compliance Officer | — | _______________ | Aug 2026 |

---

*Document controlled by: Business Analysis Team · IndoSynth Gramin Bank BI Project*
*Version: 1.0 · Classification: Internal — Project Use Only*
*Next Scheduled Review: February 2027 (or upon any material change in project scope)*
