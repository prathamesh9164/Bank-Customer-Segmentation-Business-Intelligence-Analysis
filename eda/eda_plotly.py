# ============================================================
# 🏦 IndoSynth Gramin Bank — Complete EDA with Plotly
# ============================================================
# Run: pip install pandas numpy plotly scipy kaleido
# Then: python eda_plotly.py
# ============================================================

import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from scipy import stats
import warnings
import os

warnings.filterwarnings('ignore')

# ── Create output directory for saved charts ──
os.makedirs('charts', exist_ok=True)

# ============================================================
# 1. DATA LOADING
# ============================================================

DATA_PATH = r"B:\Major Project\data"

print("Loading data...")
regions        = pd.read_csv(f"{DATA_PATH}/regions.csv")
loan_types     = pd.read_csv(f"{DATA_PATH}/loan_types.csv")
branches       = pd.read_csv(f"{DATA_PATH}/branches.csv")
employees      = pd.read_csv(f"{DATA_PATH}/employees.csv")
customers      = pd.read_csv(f"{DATA_PATH}/customers.csv")
credit_history = pd.read_csv(f"{DATA_PATH}/credit_history.csv")
loan_apps      = pd.read_csv(f"{DATA_PATH}/loan_applications.csv")
loan_payments  = pd.read_csv(f"{DATA_PATH}/loan_payments.csv")
transactions   = pd.read_csv(f"{DATA_PATH}/transactions.csv")

print("\n✅ Data loaded successfully!\n")
print(f"{'Table':<20} {'Rows':>10} {'Cols':>5}")
print("─" * 37)
for name, df in [('regions', regions), ('loan_types', loan_types),
                  ('branches', branches), ('employees', employees),
                  ('customers', customers), ('credit_history', credit_history),
                  ('loan_apps', loan_apps), ('loan_payments', loan_payments),
                  ('transactions', transactions)]:
    print(f"  {name:<18} {df.shape[0]:>10,} {df.shape[1]:>5}")


# ============================================================
# 2. DATA CLEANING
# ============================================================

# Convert date columns
date_cols = {
    'customers': ['date_of_birth', 'account_open_date'],
    'employees': ['date_of_birth', 'joining_date'],
    'branches': ['established_date'],
    'credit_history': ['last_updated_date'],
    'loan_apps': ['application_date', 'disbursement_date'],
    'loan_payments': ['due_date', 'payment_date'],
    'transactions': ['transaction_date']
}

dataframes = {
    'customers': customers, 'employees': employees, 'branches': branches,
    'credit_history': credit_history, 'loan_apps': loan_apps,
    'loan_payments': loan_payments, 'transactions': transactions
}

for tbl_name, cols in date_cols.items():
    df = dataframes[tbl_name]
    for col in cols:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], errors='coerce')

print("\n✅ Date columns converted.")


# ============================================================
# PLOTLY TEMPLATE SETUP (Dark theme for premium look)
# ============================================================

# Custom color palette
COLORS = ['#636EFA', '#EF553B', '#00CC96', '#AB63FA', '#FFA15A',
          '#19D3F3', '#FF6692', '#B6E880', '#FF97FF', '#FECB52']

TEMPLATE = 'plotly_dark'  # Premium dark theme


# ============================================================
# 📌 A. CUSTOMER DEMOGRAPHICS (Charts 1-6)
# ============================================================

# ── Chart 1: Gender Distribution (Donut) ──
print("\n📊 Generating Chart 1: Gender Distribution...")
gender_counts = customers['gender'].value_counts().reset_index()
gender_counts.columns = ['Gender', 'Count']

fig1 = px.pie(gender_counts, values='Count', names='Gender',
              title='👥 Customer Gender Distribution',
              hole=0.45, color_discrete_sequence=COLORS,
              template=TEMPLATE)
fig1.update_traces(textinfo='percent+label', textfont_size=14,
                   pull=[0.03, 0.03, 0.03])
fig1.update_layout(font=dict(size=14), title_font_size=20,
                   width=700, height=500)
fig1.write_html('charts/01_gender_distribution.html')
fig1.show()


# ── Chart 2: Age Distribution (Histogram + KDE style) ──
print("📊 Generating Chart 2: Age Distribution...")
fig2 = px.histogram(customers, x='age', nbins=50,
                    title='📈 Customer Age Distribution',
                    color_discrete_sequence=['#636EFA'],
                    template=TEMPLATE, marginal='box',
                    labels={'age': 'Age (Years)', 'count': 'Customers'})
fig2.update_layout(font=dict(size=14), title_font_size=20,
                   width=900, height=500,
                   bargap=0.05)
fig2.write_html('charts/02_age_distribution.html')
fig2.show()


# ── Chart 3: Customer Segment Breakdown (Bar) ──
print("📊 Generating Chart 3: Customer Segments...")
seg_counts = customers['customer_segment'].value_counts().reset_index()
seg_counts.columns = ['Segment', 'Count']

fig3 = px.bar(seg_counts, x='Segment', y='Count',
              title='🏷️ Customer Segment Breakdown',
              color='Segment', color_discrete_sequence=COLORS,
              template=TEMPLATE, text='Count')
fig3.update_traces(textposition='outside', textfont_size=14)
fig3.update_layout(font=dict(size=14), title_font_size=20,
                   showlegend=False, width=700, height=500)
fig3.write_html('charts/03_customer_segments.html')
fig3.show()


# ── Chart 4: Income Distribution by Employment Type (Box) ──
print("📊 Generating Chart 4: Income by Employment Type...")
emp_order = customers.groupby('employment_type')['annual_income'].median().sort_values(ascending=False).index.tolist()

fig4 = px.box(customers, x='employment_type', y='annual_income',
              title='💰 Income Distribution by Employment Type',
              color='employment_type', category_orders={'employment_type': emp_order},
              color_discrete_sequence=COLORS, template=TEMPLATE,
              labels={'employment_type': 'Employment Type', 'annual_income': 'Annual Income (₹)'})
fig4.update_layout(font=dict(size=13), title_font_size=20,
                   showlegend=False, width=1000, height=550,
                   yaxis=dict(range=[0, customers['annual_income'].quantile(0.98)]))
fig4.write_html('charts/04_income_by_employment.html')
fig4.show()


# ── Chart 5: Top 15 States by Customer Count (Horizontal Bar) ──
print("📊 Generating Chart 5: Customers by State...")
state_counts = customers['state'].value_counts().head(15).reset_index()
state_counts.columns = ['State', 'Customers']
state_counts = state_counts.sort_values('Customers', ascending=True)

fig5 = px.bar(state_counts, x='Customers', y='State', orientation='h',
              title='🗺️ Top 15 States by Customer Count',
              color='Customers', color_continuous_scale='Viridis',
              template=TEMPLATE, text='Customers')
fig5.update_traces(textposition='outside', textfont_size=12)
fig5.update_layout(font=dict(size=13), title_font_size=20,
                   width=900, height=600, coloraxis_showscale=False)
fig5.write_html('charts/05_customers_by_state.html')
fig5.show()


# ── Chart 6: Education vs Income (Violin Plot) ──
print("📊 Generating Chart 6: Education vs Income...")
edu_order = ['Illiterate', 'SSC/HSC', 'Diploma', 'Graduate', 'Post-Graduate', 'PhD']
edu_data = customers[customers['education'].isin(edu_order)].copy()

fig6 = px.violin(edu_data, x='education', y='annual_income',
                 title='🎓 Income Distribution by Education Level',
                 color='education', category_orders={'education': edu_order},
                 color_discrete_sequence=COLORS, template=TEMPLATE,
                 box=True, points=False,
                 labels={'education': 'Education', 'annual_income': 'Annual Income (₹)'})
fig6.update_layout(font=dict(size=13), title_font_size=20,
                   showlegend=False, width=1000, height=550,
                   yaxis=dict(range=[0, 3000000]))
fig6.write_html('charts/06_education_vs_income.html')
fig6.show()


# ============================================================
# 📌 B. CREDIT ANALYSIS (Charts 7-10)
# ============================================================

# ── Chart 7: Credit Score Distribution (Histogram) ──
print("📊 Generating Chart 7: Credit Score Distribution...")
fig7 = px.histogram(credit_history, x='credit_score', nbins=60,
                    title='📊 Credit Score Distribution',
                    color_discrete_sequence=['#636EFA'],
                    template=TEMPLATE, marginal='violin',
                    labels={'credit_score': 'Credit Score'})
mean_score = credit_history['credit_score'].mean()
median_score = credit_history['credit_score'].median()
fig7.add_vline(x=mean_score, line_dash="dash", line_color="red",
               annotation_text=f"Mean: {mean_score:.0f}", annotation_position="top")
fig7.add_vline(x=median_score, line_dash="dash", line_color="lime",
               annotation_text=f"Median: {median_score:.0f}", annotation_position="top left")
fig7.update_layout(font=dict(size=14), title_font_size=20,
                   width=900, height=500, bargap=0.03)
fig7.write_html('charts/07_credit_score_distribution.html')
fig7.show()


# ── Chart 8: Credit Rating Distribution (Bar with colors) ──
print("📊 Generating Chart 8: Credit Ratings...")
rating_order = ['Poor', 'Fair', 'Good', 'Very Good', 'Excellent']
rating_colors = {'Poor': '#EF553B', 'Fair': '#FFA15A', 'Good': '#FECB52',
                 'Very Good': '#00CC96', 'Excellent': '#636EFA'}
rating_counts = credit_history['credit_rating'].value_counts().reindex(rating_order).reset_index()
rating_counts.columns = ['Rating', 'Count']

fig8 = px.bar(rating_counts, x='Rating', y='Count',
              title='⭐ Credit Rating Distribution',
              color='Rating', color_discrete_map=rating_colors,
              template=TEMPLATE, text='Count',
              category_orders={'Rating': rating_order})
fig8.update_traces(textposition='outside', textfont_size=14)
fig8.update_layout(font=dict(size=14), title_font_size=20,
                   showlegend=False, width=800, height=500)
fig8.write_html('charts/08_credit_ratings.html')
fig8.show()


# ── Chart 9: Credit Features Correlation Heatmap ──
print("📊 Generating Chart 9: Credit Correlation Heatmap...")
credit_cols = ['credit_score', 'number_of_accounts', 'number_of_delinquencies',
               'total_outstanding_debt', 'credit_utilization_pct',
               'payment_history_pct', 'hard_inquiries_last_6m', 'oldest_account_years']
credit_corr = credit_history[credit_cols].corr()

fig9 = px.imshow(credit_corr, text_auto='.2f',
                 title='🔗 Credit Features Correlation Matrix',
                 color_continuous_scale='RdYlBu_r',
                 template=TEMPLATE, aspect='auto',
                 labels=dict(color='Correlation'))
fig9.update_layout(font=dict(size=11), title_font_size=20,
                   width=800, height=700)
fig9.write_html('charts/09_credit_correlation.html')
fig9.show()


# ── Chart 10: Credit Utilization vs Credit Score (Scatter) ──
print("📊 Generating Chart 10: Utilization vs Score...")
sample_credit = credit_history.sample(5000, random_state=42)

fig10 = px.scatter(sample_credit, x='credit_utilization_pct', y='credit_score',
                   color='credit_rating', title='🎯 Credit Utilization vs Credit Score',
                   color_discrete_map=rating_colors,
                   category_orders={'credit_rating': rating_order},
                   template=TEMPLATE, opacity=0.6,
                   labels={'credit_utilization_pct': 'Credit Utilization (%)',
                           'credit_score': 'Credit Score'})
fig10.update_layout(font=dict(size=13), title_font_size=20,
                    width=900, height=550)
fig10.write_html('charts/10_utilization_vs_score.html')
fig10.show()


# ============================================================
# 📌 C. LOAN ANALYSIS (Charts 11-16)
# ============================================================

# ── Chart 11: Loan Application Status Distribution (Donut) ──
print("📊 Generating Chart 11: Loan Status Distribution...")
status_counts = loan_apps['status'].value_counts().reset_index()
status_counts.columns = ['Status', 'Count']

status_colors = {'Disbursed': '#00CC96', 'Approved': '#636EFA',
                 'Rejected': '#EF553B', 'Closed': '#AB63FA',
                 'Pending': '#FFA15A', 'Under Review': '#19D3F3'}

fig11 = px.pie(status_counts, values='Count', names='Status',
               title='📋 Loan Application Status Distribution',
               hole=0.4, color='Status', color_discrete_map=status_colors,
               template=TEMPLATE)
fig11.update_traces(textinfo='percent+label', textfont_size=13)
fig11.update_layout(font=dict(size=14), title_font_size=20,
                    width=750, height=550)
fig11.write_html('charts/11_loan_status_distribution.html')
fig11.show()


# ── Chart 12: Loan Amount Requested vs Approved (Scatter) ──
print("📊 Generating Chart 12: Requested vs Approved Amount...")
disbursed_apps = loan_apps[loan_apps['status'] == 'Disbursed'].sample(5000, random_state=42)

fig12 = px.scatter(disbursed_apps, x='loan_amount_requested', y='loan_amount_approved',
                   color='loan_type_name',
                   title='💵 Loan Amount: Requested vs Approved',
                   template=TEMPLATE, opacity=0.5,
                   color_discrete_sequence=COLORS,
                   labels={'loan_amount_requested': 'Amount Requested (₹)',
                           'loan_amount_approved': 'Amount Approved (₹)'})
# Add 45-degree reference line
max_val = max(disbursed_apps['loan_amount_requested'].max(),
              disbursed_apps['loan_amount_approved'].max())
fig12.add_shape(type='line', x0=0, y0=0, x1=max_val, y1=max_val,
                line=dict(dash='dash', color='rgba(255,255,255,0.3)'))
fig12.update_layout(font=dict(size=13), title_font_size=20,
                    width=950, height=600)
fig12.write_html('charts/12_requested_vs_approved.html')
fig12.show()


# ── Chart 13: Approval Rate by Credit Score Band (Grouped Bar) ──
print("📊 Generating Chart 13: Approval Rate by Credit Band...")
merged_la_ch = loan_apps.merge(credit_history[['customer_id', 'credit_score']], on='customer_id')
merged_la_ch['credit_band'] = pd.cut(merged_la_ch['credit_score'],
                                      bins=[0, 600, 700, 800, 900],
                                      labels=['Below 600 (Poor)', '600-699 (Fair)',
                                              '700-799 (Good)', '800+ (Excellent)'])
band_status = merged_la_ch.groupby(['credit_band', 'status']).size().reset_index(name='count')

fig13 = px.bar(band_status, x='credit_band', y='count', color='status',
               title='📊 Loan Status by Credit Score Band',
               barmode='group', template=TEMPLATE,
               color_discrete_map=status_colors,
               labels={'credit_band': 'Credit Score Band', 'count': 'Applications'})
fig13.update_layout(font=dict(size=13), title_font_size=20,
                    width=950, height=550)
fig13.write_html('charts/13_approval_by_credit_band.html')
fig13.show()


# ── Chart 14: Top Rejection Reasons (Horizontal Bar) ──
print("📊 Generating Chart 14: Top Rejection Reasons...")
rejected = loan_apps[loan_apps['status'] == 'Rejected']
rejection_reasons = rejected['rejection_reason'].value_counts().head(10).reset_index()
rejection_reasons.columns = ['Reason', 'Count']
rejection_reasons = rejection_reasons.sort_values('Count', ascending=True)

fig14 = px.bar(rejection_reasons, x='Count', y='Reason', orientation='h',
               title='❌ Top 10 Loan Rejection Reasons',
               color='Count', color_continuous_scale='Reds',
               template=TEMPLATE, text='Count')
fig14.update_traces(textposition='outside', textfont_size=12)
fig14.update_layout(font=dict(size=12), title_font_size=20,
                    width=900, height=550, coloraxis_showscale=False)
fig14.write_html('charts/14_rejection_reasons.html')
fig14.show()


# ── Chart 15: Disbursed Amount by Loan Type (Treemap) ──
print("📊 Generating Chart 15: Disbursement Treemap...")
disbursed_by_type = loan_apps[loan_apps['status'] == 'Disbursed'].groupby('loan_type_name').agg(
    total_disbursed=('loan_amount_approved', 'sum'),
    count=('application_id', 'count'),
    avg_amount=('loan_amount_approved', 'mean')
).reset_index()
disbursed_by_type['total_cr'] = (disbursed_by_type['total_disbursed'] / 1e7).round(2)
disbursed_by_type['label'] = disbursed_by_type['loan_type_name'] + '<br>₹' + \
                              disbursed_by_type['total_cr'].astype(str) + ' Cr'

fig15 = px.treemap(disbursed_by_type, path=['label'], values='total_disbursed',
                   color='count', color_continuous_scale='Viridis',
                   title='🌳 Total Disbursed Amount by Loan Type (Treemap)',
                   template=TEMPLATE)
fig15.update_traces(textinfo='label+value', textfont_size=14)
fig15.update_layout(font=dict(size=13), title_font_size=20,
                    width=950, height=600)
fig15.write_html('charts/15_disbursement_treemap.html')
fig15.show()


# ── Chart 16: Monthly Loan Application Trend (Line) ──
print("📊 Generating Chart 16: Monthly Loan Trend...")
loan_apps['app_month'] = loan_apps['application_date'].dt.to_period('M').astype(str)
monthly_status = loan_apps.groupby(['app_month', 'status']).size().reset_index(name='count')

fig16 = px.area(monthly_status, x='app_month', y='count', color='status',
                title='📈 Monthly Loan Application Trend by Status',
                template=TEMPLATE, color_discrete_map=status_colors,
                labels={'app_month': 'Month', 'count': 'Applications'})
fig16.update_layout(font=dict(size=12), title_font_size=20,
                    width=1100, height=550,
                    xaxis=dict(tickangle=-45, dtick=3))
fig16.write_html('charts/16_monthly_loan_trend.html')
fig16.show()


# ============================================================
# 📌 D. PAYMENT BEHAVIOR (Charts 17-21)
# ============================================================

# ── Chart 17: Payment Status Distribution (Donut) ──
print("📊 Generating Chart 17: Payment Status...")
pay_status = loan_payments['payment_status'].value_counts().reset_index()
pay_status.columns = ['Status', 'Count']

pay_colors = {'Paid': '#00CC96', 'Late': '#FFA15A', 'Missed': '#EF553B'}

fig17 = px.pie(pay_status, values='Count', names='Status',
               title='💳 Payment Status Distribution',
               hole=0.45, color='Status', color_discrete_map=pay_colors,
               template=TEMPLATE)
fig17.update_traces(textinfo='percent+label+value', textfont_size=13)
fig17.update_layout(font=dict(size=14), title_font_size=20,
                    width=700, height=500)
fig17.write_html('charts/17_payment_status.html')
fig17.show()


# ── Chart 18: Distribution of Days Late (Histogram) ──
print("📊 Generating Chart 18: Days Late Distribution...")
late_payments = loan_payments[loan_payments['days_late'] > 0].copy()
late_payments['days_late_clipped'] = late_payments['days_late'].clip(upper=90)

fig18 = px.histogram(late_payments, x='days_late_clipped', nbins=45,
                     title='⏰ Distribution of Days Late (Clipped at 90)',
                     color_discrete_sequence=['#EF553B'],
                     template=TEMPLATE, marginal='box',
                     labels={'days_late_clipped': 'Days Late'})
fig18.update_layout(font=dict(size=14), title_font_size=20,
                    width=900, height=500, bargap=0.05)
fig18.write_html('charts/18_days_late_distribution.html')
fig18.show()


# ── Chart 19: Penalty Amount by Loan Type (Bar) ──
print("📊 Generating Chart 19: Penalty by Loan Type...")
penalty_by_type = loan_payments.merge(
    loan_apps[['application_id', 'loan_type_name']], on='application_id'
).groupby('loan_type_name').agg(
    total_penalty=('penalty_amount', 'sum'),
    avg_penalty=('penalty_amount', 'mean')
).reset_index().sort_values('total_penalty', ascending=False)
penalty_by_type['total_penalty_lakhs'] = (penalty_by_type['total_penalty'] / 1e5).round(2)

fig19 = px.bar(penalty_by_type, x='loan_type_name', y='total_penalty_lakhs',
               title='💸 Total Penalty Amount by Loan Type (₹ Lakhs)',
               color='total_penalty_lakhs', color_continuous_scale='OrRd',
               template=TEMPLATE, text='total_penalty_lakhs',
               labels={'loan_type_name': 'Loan Type', 'total_penalty_lakhs': 'Penalty (₹ Lakhs)'})
fig19.update_traces(textposition='outside', textfont_size=12)
fig19.update_layout(font=dict(size=12), title_font_size=20,
                    width=1000, height=550, coloraxis_showscale=False,
                    xaxis_tickangle=-30)
fig19.write_html('charts/19_penalty_by_loan_type.html')
fig19.show()


# ── Chart 20: Missed Payment Rate Over Time (Line) ──
print("📊 Generating Chart 20: Missed Payment Trend...")
loan_payments['pay_month'] = loan_payments['due_date'].dt.to_period('M').astype(str)
monthly_pay = loan_payments.groupby('pay_month').agg(
    total=('payment_id', 'count'),
    missed=('payment_status', lambda x: (x == 'Missed').sum()),
    late=('payment_status', lambda x: (x == 'Late').sum())
).reset_index()
monthly_pay['missed_rate'] = (monthly_pay['missed'] / monthly_pay['total'] * 100).round(2)
monthly_pay['late_rate'] = (monthly_pay['late'] / monthly_pay['total'] * 100).round(2)

fig20 = go.Figure()
fig20.add_trace(go.Scatter(x=monthly_pay['pay_month'], y=monthly_pay['missed_rate'],
                           mode='lines+markers', name='Missed Rate %',
                           line=dict(color='#EF553B', width=2)))
fig20.add_trace(go.Scatter(x=monthly_pay['pay_month'], y=monthly_pay['late_rate'],
                           mode='lines+markers', name='Late Rate %',
                           line=dict(color='#FFA15A', width=2)))
fig20.update_layout(title='📉 Missed & Late Payment Rate Over Time',
                    xaxis_title='Month', yaxis_title='Rate (%)',
                    template=TEMPLATE, font=dict(size=13), title_font_size=20,
                    width=1100, height=500,
                    xaxis=dict(tickangle=-45, dtick=3))
fig20.write_html('charts/20_missed_payment_trend.html')
fig20.show()


# ── Chart 21: Outstanding Balance Distribution (Histogram) ──
print("📊 Generating Chart 21: Outstanding Balance...")
fig21 = px.histogram(loan_payments[loan_payments['outstanding_balance'] > 0],
                     x='outstanding_balance', nbins=60,
                     title='🏦 Outstanding Balance Distribution',
                     color_discrete_sequence=['#AB63FA'],
                     template=TEMPLATE, marginal='box',
                     labels={'outstanding_balance': 'Outstanding Balance (₹)'})
fig21.update_layout(font=dict(size=14), title_font_size=20,
                    width=900, height=500, bargap=0.03)
fig21.write_html('charts/21_outstanding_balance.html')
fig21.show()


# ============================================================
# 📌 E. TRANSACTION PATTERNS (Charts 22-25)
# ============================================================

# ── Chart 22: Transaction Type Split — Credit vs Debit (Donut) ──
print("📊 Generating Chart 22: Transaction Type Split...")
txn_type = transactions['transaction_type'].value_counts().reset_index()
txn_type.columns = ['Type', 'Count']

fig22 = px.pie(txn_type, values='Count', names='Type',
               title='🔄 Transaction Type Split (Credit vs Debit)',
               hole=0.45, color='Type',
               color_discrete_map={'Credit': '#00CC96', 'Debit': '#EF553B'},
               template=TEMPLATE)
fig22.update_traces(textinfo='percent+label+value', textfont_size=14)
fig22.update_layout(font=dict(size=14), title_font_size=20,
                    width=700, height=500)
fig22.write_html('charts/22_txn_type_split.html')
fig22.show()


# ── Chart 23: Top Spending Categories — Debit (Bar) ──
print("📊 Generating Chart 23: Top Spending Categories...")
debit_txns = transactions[(transactions['transaction_type'] == 'Debit') &
                           (transactions['status'] == 'Success')]
cat_spend = debit_txns.groupby('category').agg(
    total_spent=('amount', 'sum'),
    txn_count=('transaction_id', 'count'),
    avg_spent=('amount', 'mean')
).reset_index().sort_values('total_spent', ascending=True)
cat_spend['total_cr'] = (cat_spend['total_spent'] / 1e7).round(2)

fig23 = px.bar(cat_spend, x='total_cr', y='category', orientation='h',
               title='🛒 Top Spending Categories (Debit Transactions)',
               color='total_cr', color_continuous_scale='Plasma',
               template=TEMPLATE, text='total_cr',
               labels={'category': 'Category', 'total_cr': 'Total Spent (₹ Cr)'})
fig23.update_traces(textposition='outside', textfont_size=11)
fig23.update_layout(font=dict(size=12), title_font_size=20,
                    width=950, height=650, coloraxis_showscale=False)
fig23.write_html('charts/23_spending_categories.html')
fig23.show()


# ── Chart 24: Transaction Mode Trend Over Years (Stacked %) ──
print("📊 Generating Chart 24: Transaction Mode Trend...")
transactions['year'] = transactions['transaction_date'].dt.year
mode_year = transactions.groupby(['year', 'transaction_mode']).size().reset_index(name='count')
mode_year_total = mode_year.groupby('year')['count'].transform('sum')
mode_year['pct'] = (mode_year['count'] / mode_year_total * 100).round(2)

fig24 = px.bar(mode_year, x='year', y='pct', color='transaction_mode',
               title='📱 Transaction Mode Share Over Years (UPI Growth Story)',
               template=TEMPLATE, color_discrete_sequence=COLORS,
               labels={'year': 'Year', 'pct': 'Share (%)', 'transaction_mode': 'Mode'},
               text='pct')
fig24.update_traces(texttemplate='%{text:.1f}%', textposition='inside', textfont_size=9)
fig24.update_layout(font=dict(size=13), title_font_size=20,
                    barmode='stack', width=1000, height=550)
fig24.write_html('charts/24_txn_mode_trend.html')
fig24.show()


# ── Chart 25: Monthly Transaction Volume Heatmap (Year × Month) ──
print("📊 Generating Chart 25: Transaction Volume Heatmap...")
transactions['month'] = transactions['transaction_date'].dt.month
txn_heatmap = transactions.groupby(['year', 'month']).size().reset_index(name='count')
txn_pivot = txn_heatmap.pivot(index='year', columns='month', values='count').fillna(0)
month_names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

fig25 = px.imshow(txn_pivot, text_auto='.0f',
                  title='🗓️ Monthly Transaction Volume Heatmap (Year × Month)',
                  color_continuous_scale='YlOrRd',
                  template=TEMPLATE, aspect='auto',
                  labels=dict(x='Month', y='Year', color='Transactions'),
                  x=month_names[:txn_pivot.shape[1]],
                  y=txn_pivot.index.astype(str).tolist())
fig25.update_layout(font=dict(size=13), title_font_size=20,
                    width=950, height=500)
fig25.write_html('charts/25_txn_volume_heatmap.html')
fig25.show()


# ============================================================
# 📌 F. ADVANCED ANALYTICS (Charts 26-30)
# ============================================================

# ── Chart 26: Credit Score Band vs Default Rate ──
print("📊 Generating Chart 26: Credit Band vs Default Rate...")
merged_risk = loan_apps.merge(credit_history[['customer_id', 'credit_score']], on='customer_id')
merged_risk = merged_risk[merged_risk['status'].isin(['Disbursed', 'Closed'])]
merged_risk['credit_band'] = pd.cut(merged_risk['credit_score'],
                                     bins=[0, 600, 700, 800, 900],
                                     labels=['Below 600', '600-699', '700-799', '800+'])

# Merge with payments to find defaults
risk_payments = merged_risk.merge(
    loan_payments[['application_id', 'payment_status']], on='application_id')
risk_summary = risk_payments.groupby('credit_band').agg(
    total_payments=('payment_status', 'count'),
    missed=('payment_status', lambda x: (x == 'Missed').sum())
).reset_index()
risk_summary['default_rate'] = (risk_summary['missed'] / risk_summary['total_payments'] * 100).round(2)

fig26 = px.bar(risk_summary, x='credit_band', y='default_rate',
               title='⚠️ Default Rate by Credit Score Band',
               color='default_rate', color_continuous_scale='RdYlGn_r',
               template=TEMPLATE, text='default_rate',
               labels={'credit_band': 'Credit Score Band', 'default_rate': 'Default Rate (%)'})
fig26.update_traces(texttemplate='%{text:.2f}%', textposition='outside', textfont_size=14)
fig26.update_layout(font=dict(size=14), title_font_size=20,
                    showlegend=False, width=800, height=500, coloraxis_showscale=False)
fig26.write_html('charts/26_credit_band_vs_default.html')
fig26.show()


# ── Chart 27: Zone-wise Loan Disbursement (Sunburst) ──
print("📊 Generating Chart 27: Zone-wise Disbursement Sunburst...")
zone_disb = loan_apps[loan_apps['status'] == 'Disbursed'].merge(
    customers[['customer_id', 'zone', 'state']], on='customer_id'
).groupby(['zone', 'state']).agg(
    disbursed_amount=('loan_amount_approved', 'sum'),
    count=('application_id', 'count')
).reset_index()
zone_disb['amount_cr'] = (zone_disb['disbursed_amount'] / 1e7).round(2)

fig27 = px.sunburst(zone_disb, path=['zone', 'state'], values='disbursed_amount',
                    color='amount_cr', color_continuous_scale='Viridis',
                    title='🌍 Zone-wise Loan Disbursement (Sunburst)',
                    template=TEMPLATE)
fig27.update_layout(font=dict(size=13), title_font_size=20,
                    width=850, height=700)
fig27.write_html('charts/27_zone_disbursement_sunburst.html')
fig27.show()


# ── Chart 28: Loan Officer Performance (Scatter — Bubble) ──
print("📊 Generating Chart 28: Loan Officer Performance...")
officer_perf = loan_apps.merge(
    employees[['employee_id', 'full_name', 'designation']], 
    left_on='officer_employee_id', right_on='employee_id'
).groupby(['full_name', 'designation']).agg(
    total_processed=('application_id', 'count'),
    disbursed=('status', lambda x: (x == 'Disbursed').sum()),
    total_approved_amount=('loan_amount_approved', 'sum')
).reset_index()
officer_perf = officer_perf[officer_perf['total_processed'] >= 10]
officer_perf['success_rate'] = (officer_perf['disbursed'] / officer_perf['total_processed'] * 100).round(2)
officer_perf['amount_lakhs'] = (officer_perf['total_approved_amount'] / 1e5).round(2)

fig28 = px.scatter(officer_perf.head(50), x='total_processed', y='success_rate',
                   size='amount_lakhs', color='designation',
                   hover_name='full_name',
                   title='👔 Loan Officer Performance (Bubble Chart)',
                   template=TEMPLATE, color_discrete_sequence=COLORS,
                   labels={'total_processed': 'Total Applications Processed',
                           'success_rate': 'Disbursement Success Rate (%)',
                           'amount_lakhs': 'Amount (₹ Lakhs)'})
fig28.update_layout(font=dict(size=13), title_font_size=20,
                    width=950, height=600)
fig28.write_html('charts/28_officer_performance.html')
fig28.show()


# ── Chart 29: Cohort Analysis — Loan Applications by Account Year ──
print("📊 Generating Chart 29: Cohort Analysis...")
cohort_data = loan_apps.merge(customers[['customer_id', 'account_open_date']], on='customer_id')
cohort_data['cohort_year'] = cohort_data['account_open_date'].dt.year
cohort_data['app_year'] = cohort_data['application_date'].dt.year
cohort_summary = cohort_data.groupby(['cohort_year', 'app_year']).size().reset_index(name='applications')

fig29 = px.density_heatmap(cohort_summary, x='app_year', y='cohort_year',
                           z='applications', histfunc='sum',
                           title='📅 Cohort Analysis — Applications by Account Opening Year',
                           template=TEMPLATE, color_continuous_scale='Magma',
                           labels={'app_year': 'Application Year',
                                   'cohort_year': 'Account Opening Year',
                                   'applications': 'Applications'})
fig29.update_layout(font=dict(size=13), title_font_size=20,
                    width=900, height=600)
fig29.write_html('charts/29_cohort_analysis.html')
fig29.show()


# ── Chart 30: KPI Summary Dashboard (Indicators) ──
print("📊 Generating Chart 30: KPI Dashboard...")
total_customers = len(customers)
total_applications = len(loan_apps)
approval_rate = (loan_apps['status'].isin(['Disbursed', 'Approved', 'Closed']).sum() / total_applications * 100)
total_disbursed_cr = loan_apps[loan_apps['status'] == 'Disbursed']['loan_amount_approved'].sum() / 1e7
on_time_rate = (loan_payments['payment_status'] == 'Paid').sum() / len(loan_payments) * 100
default_rate = (loan_payments['payment_status'] == 'Missed').sum() / len(loan_payments) * 100
avg_credit = credit_history['credit_score'].mean()
total_txns = len(transactions)

fig30 = make_subplots(rows=2, cols=4,
                      specs=[[{"type": "indicator"}]*4, [{"type": "indicator"}]*4],
                      subplot_titles=[])

indicators = [
    ('Total Customers', total_customers, '#636EFA', ''),
    ('Total Applications', total_applications, '#AB63FA', ''),
    ('Approval Rate', round(approval_rate, 1), '#00CC96', '%'),
    ('Disbursed (₹ Cr)', round(total_disbursed_cr, 1), '#FFA15A', ''),
    ('On-Time Pay Rate', round(on_time_rate, 1), '#00CC96', '%'),
    ('Default Rate', round(default_rate, 1), '#EF553B', '%'),
    ('Avg Credit Score', round(avg_credit, 0), '#19D3F3', ''),
    ('Total Transactions', total_txns, '#FF6692', ''),
]

for i, (title, value, color, suffix) in enumerate(indicators):
    row = (i // 4) + 1
    col = (i % 4) + 1
    fig30.add_trace(go.Indicator(
        mode="number",
        value=value,
        title=dict(text=title, font=dict(size=14)),
        number=dict(font=dict(size=28, color=color), suffix=suffix)
    ), row=row, col=col)

fig30.update_layout(title='🏦 IndoSynth Gramin Bank — KPI Dashboard',
                    template=TEMPLATE, title_font_size=22,
                    width=1100, height=400, margin=dict(t=80, b=30))
fig30.write_html('charts/30_kpi_dashboard.html')
fig30.show()


# ============================================================
# 📌 G. STATISTICAL TESTS
# ============================================================

print("\n" + "="*60)
print("📊 STATISTICAL TESTS")
print("="*60)

# ── Test 1: T-Test — Income of Approved vs Rejected Applicants ──
merged_income = loan_apps.merge(customers[['customer_id', 'annual_income']], on='customer_id')
approved_income = merged_income[merged_income['status'].isin(['Disbursed', 'Approved', 'Closed'])]['annual_income']
rejected_income = merged_income[merged_income['status'] == 'Rejected']['annual_income']

t_stat, p_value = stats.ttest_ind(approved_income, rejected_income, equal_var=False)
print(f"\n🔬 Test 1: T-Test — Income (Approved vs Rejected)")
print(f"   T-statistic: {t_stat:.4f}")
print(f"   P-value:     {p_value:.6f}")
print(f"   Result:      {'✅ Significant difference' if p_value < 0.05 else '❌ No significant difference'}")

# ── Test 2: Chi-Square — Loan Approval vs Gender ──
merged_gender = loan_apps.merge(customers[['customer_id', 'gender']], on='customer_id')
merged_gender['is_approved'] = merged_gender['status'].isin(['Disbursed', 'Approved', 'Closed'])
contingency = pd.crosstab(merged_gender['gender'], merged_gender['is_approved'])
chi2, p_chi, dof, expected = stats.chi2_contingency(contingency)
print(f"\n🔬 Test 2: Chi-Square — Loan Approval vs Gender")
print(f"   Chi²:    {chi2:.4f}")
print(f"   P-value: {p_chi:.6f}")
print(f"   Result:  {'✅ Dependent (approval differs by gender)' if p_chi < 0.05 else '❌ Independent'}")

# ── Test 3: ANOVA — Credit Score Across Zones ──
merged_zone = credit_history.merge(customers[['customer_id', 'zone']], on='customer_id')
zone_groups = [group['credit_score'].values for _, group in merged_zone.groupby('zone')]
f_stat, p_anova = stats.f_oneway(*zone_groups)
print(f"\n🔬 Test 3: ANOVA — Credit Score Across Zones")
print(f"   F-statistic: {f_stat:.4f}")
print(f"   P-value:     {p_anova:.6f}")
print(f"   Result:      {'✅ Significant difference across zones' if p_anova < 0.05 else '❌ No significant difference'}")

# ── Test 4: Pearson Correlation — Credit Score vs Loan Amount ──
merged_corr = loan_apps.merge(credit_history[['customer_id', 'credit_score']], on='customer_id')
corr_val, p_corr = stats.pearsonr(merged_corr['credit_score'], merged_corr['loan_amount_requested'])
print(f"\n🔬 Test 4: Pearson Correlation — Credit Score vs Loan Amount")
print(f"   Correlation: {corr_val:.4f}")
print(f"   P-value:     {p_corr:.6f}")
print(f"   Result:      {'✅ Significant correlation' if p_corr < 0.05 else '❌ No significant correlation'}")


# ============================================================
print("\n\n" + "="*60)
print("✅ ALL 30 CHARTS GENERATED SUCCESSFULLY!")
print(f"📁 Saved to: {os.path.abspath('charts')}/")
print("="*60)
print("\nCharts saved as interactive HTML files.")
print("Open any .html file in your browser for full interactivity!")
