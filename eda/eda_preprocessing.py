# ============================================================
# 🏦 IndoSynth Gramin Bank — EDA Preprocessing
# ============================================================
# This script covers all data-cleaning and preprocessing steps
# BEFORE the visual EDA (eda_plotly.py).
#
# Sections:
#   1. Data Loading & Shape Overview
#   2. Data Types & Info
#   3. Missing Value Analysis
#   4. Duplicate Detection
#   5. Date Column Conversion
#   6. Categorical Standardization
#   7. Numerical Outlier Detection (IQR)
#   8. Feature Engineering (Derived Columns)
#   9. Export Cleaned Data
#
# Run:  pip install pandas numpy
# Then: python eda_preprocessing.py
# ============================================================

import pandas as pd
import numpy as np
import warnings
import os

warnings.filterwarnings('ignore')

# ── Paths ──
DATA_PATH = r"B:\Major Project\data"
CLEAN_PATH = os.path.join(r"B:\Major Project", "eda", "cleaned_data")
os.makedirs(CLEAN_PATH, exist_ok=True)


# ============================================================
# 1. DATA LOADING & SHAPE OVERVIEW
# ============================================================

print("=" * 65)
print("  🏦 IndoSynth Gramin Bank — EDA Preprocessing Pipeline")
print("=" * 65)

print("\n📥 Step 1: Loading all datasets...\n")

regions        = pd.read_csv(f"{DATA_PATH}/regions.csv")
loan_types     = pd.read_csv(f"{DATA_PATH}/loan_types.csv")
branches       = pd.read_csv(f"{DATA_PATH}/branches.csv")
employees      = pd.read_csv(f"{DATA_PATH}/employees.csv")
customers      = pd.read_csv(f"{DATA_PATH}/customers.csv")
credit_history = pd.read_csv(f"{DATA_PATH}/credit_history.csv")
loan_apps      = pd.read_csv(f"{DATA_PATH}/loan_applications.csv")
loan_payments  = pd.read_csv(f"{DATA_PATH}/loan_payments.csv")
transactions   = pd.read_csv(f"{DATA_PATH}/transactions.csv")

# Dictionary for easy iteration
all_tables = {
    'regions':        regions,
    'loan_types':     loan_types,
    'branches':       branches,
    'employees':      employees,
    'customers':      customers,
    'credit_history': credit_history,
    'loan_apps':      loan_apps,
    'loan_payments':  loan_payments,
    'transactions':   transactions,
}

print(f"{'Table':<20} {'Rows':>10} {'Columns':>8} {'Memory (MB)':>12}")
print("─" * 52)
for name, df in all_tables.items():
    mem = df.memory_usage(deep=True).sum() / (1024 ** 2)
    print(f"  {name:<18} {df.shape[0]:>10,} {df.shape[1]:>8} {mem:>11.2f}")

total_rows = sum(df.shape[0] for df in all_tables.values())
print(f"\n  📊 Total records across all tables: {total_rows:,}")


# ============================================================
# 2. DATA TYPES & COLUMN INFO
# ============================================================

print("\n\n" + "=" * 65)
print("📋 Step 2: Data Types & Column Summary")
print("=" * 65)

for name, df in all_tables.items():
    print(f"\n{'─' * 50}")
    print(f"📌 {name.upper()} — {df.shape[0]:,} rows × {df.shape[1]} cols")
    print(f"{'─' * 50}")
    print(f"  {'Column':<35} {'Dtype':<12} {'Non-Null':>10} {'Nulls':>8}")
    print(f"  {'─' * 67}")
    for col in df.columns:
        non_null = df[col].notna().sum()
        nulls = df[col].isna().sum()
        dtype_str = str(df[col].dtype)
        print(f"  {col:<35} {dtype_str:<12} {non_null:>10,} {nulls:>8,}")
    print(f"\n  First 3 rows:")
    print(df.head(3).to_string(index=False))


# ============================================================
# 3. MISSING VALUE ANALYSIS
# ============================================================

print("\n\n" + "=" * 65)
print("🔍 Step 3: Missing Value Analysis")
print("=" * 65)

any_missing = False
for name, df in all_tables.items():
    missing = df.isnull().sum()
    missing = missing[missing > 0]
    if len(missing) > 0:
        any_missing = True
        pct = (missing / len(df) * 100).round(2)
        print(f"\n📌 {name.upper()}")
        print(f"  {'Column':<35} {'Missing':>8} {'% of Total':>10}")
        print(f"  {'─' * 55}")
        for col in missing.index:
            print(f"  {col:<35} {missing[col]:>8,} {pct[col]:>9.2f}%")

if not any_missing:
    print("\n  ✅ No missing values found in any table!")

# ── Handle Missing Values ──
print("\n\n🔧 Handling missing values...")

# loan_apps: rejection_reason is NULL when status != 'Rejected' → expected
if 'rejection_reason' in loan_apps.columns:
    null_rej = loan_apps['rejection_reason'].isna().sum()
    non_rejected = (loan_apps['status'] != 'Rejected').sum()
    print(f"  • loan_apps.rejection_reason: {null_rej:,} NULLs "
          f"({non_rejected:,} non-rejected) → Expected, filling with 'N/A'")
    loan_apps['rejection_reason'] = loan_apps['rejection_reason'].fillna('N/A')

# loan_apps: disbursement_date is NULL when not disbursed → expected
if 'disbursement_date' in loan_apps.columns:
    null_disb = loan_apps['disbursement_date'].isna().sum()
    print(f"  • loan_apps.disbursement_date: {null_disb:,} NULLs → "
          f"Expected for non-disbursed loans, keeping as-is")

# loan_apps: loan_amount_approved can be NULL for rejected
if 'loan_amount_approved' in loan_apps.columns:
    null_amt = loan_apps['loan_amount_approved'].isna().sum()
    print(f"  • loan_apps.loan_amount_approved: {null_amt:,} NULLs → "
          f"Filling with 0 for non-approved")
    loan_apps['loan_amount_approved'] = loan_apps['loan_amount_approved'].fillna(0)

# loan_apps: emi_amount, interest_rate_pct, processing_fee can be NULL for rejected
for col in ['emi_amount', 'interest_rate_pct', 'processing_fee']:
    if col in loan_apps.columns:
        null_count = loan_apps[col].isna().sum()
        if null_count > 0:
            print(f"  • loan_apps.{col}: {null_count:,} NULLs → Filling with 0")
            loan_apps[col] = loan_apps[col].fillna(0)

# loan_apps: collateral_type NULL when collateral_required = 0 → expected
if 'collateral_type' in loan_apps.columns:
    null_coll = loan_apps['collateral_type'].isna().sum()
    print(f"  • loan_apps.collateral_type: {null_coll:,} NULLs → "
          f"Filling with 'None' for unsecured loans")
    loan_apps['collateral_type'] = loan_apps['collateral_type'].fillna('None')

# transactions: branch_id can have NaN for digital transactions
if 'branch_id' in transactions.columns:
    null_br = transactions['branch_id'].isna().sum()
    if null_br > 0:
        print(f"  • transactions.branch_id: {null_br:,} NULLs → "
              f"Filling with -1 (online/digital)")
        transactions['branch_id'] = transactions['branch_id'].fillna(-1).astype(int)

# transactions: merchant_name can be NULL for non-merchant transactions
if 'merchant_name' in transactions.columns:
    null_merch = transactions['merchant_name'].isna().sum()
    if null_merch > 0:
        print(f"  • transactions.merchant_name: {null_merch:,} NULLs → "
              f"Filling with 'Unknown'")
        transactions['merchant_name'] = transactions['merchant_name'].fillna('Unknown')

print("\n  ✅ Missing values handled!")


# ============================================================
# 4. DUPLICATE DETECTION
# ============================================================

print("\n\n" + "=" * 65)
print("🔁 Step 4: Duplicate Detection")
print("=" * 65)

# Define primary keys for each table
primary_keys = {
    'regions':        'region_id',
    'loan_types':     'loan_type_id',
    'branches':       'branch_id',
    'employees':      'employee_id',
    'customers':      'customer_id',
    'credit_history': 'credit_history_id',
    'loan_apps':      'application_id',
    'loan_payments':  'payment_id',
    'transactions':   'transaction_id',
}

print(f"\n  {'Table':<20} {'PK Column':<22} {'Total':>10} {'Dup PKs':>8} {'Full Dups':>10}")
print(f"  {'─' * 72}")

any_dups = False
for name, df in all_tables.items():
    pk = primary_keys.get(name, None)
    full_dups = df.duplicated().sum()
    pk_dups = df[pk].duplicated().sum() if pk and pk in df.columns else 'N/A'
    if (isinstance(pk_dups, int) and pk_dups > 0) or full_dups > 0:
        any_dups = True
    pk_str = str(pk_dups) if isinstance(pk_dups, str) else f"{pk_dups:,}"
    print(f"  {name:<20} {pk or 'N/A':<22} {len(df):>10,} {pk_str:>8} {full_dups:>10,}")

if not any_dups:
    print("\n  ✅ No duplicate records found!")
else:
    print("\n  ⚠️  Duplicates detected — removing full duplicates...")
    for name in list(all_tables.keys()):
        df = all_tables[name]
        before = len(df)
        df = df.drop_duplicates()
        after = len(df)
        if before != after:
            print(f"     • {name}: Removed {before - after:,} duplicates")
            all_tables[name] = df
    # Re-assign cleaned tables
    regions = all_tables['regions']
    loan_types = all_tables['loan_types']
    branches = all_tables['branches']
    employees = all_tables['employees']
    customers = all_tables['customers']
    credit_history = all_tables['credit_history']
    loan_apps = all_tables['loan_apps']
    loan_payments = all_tables['loan_payments']
    transactions = all_tables['transactions']


# ============================================================
# 5. DATE COLUMN CONVERSION
# ============================================================

print("\n\n" + "=" * 65)
print("📅 Step 5: Date Column Conversion")
print("=" * 65)

date_columns = {
    'customers':      ['date_of_birth', 'account_open_date'],
    'employees':      ['date_of_birth', 'joining_date'],
    'branches':       ['established_date'],
    'credit_history': ['last_updated_date'],
    'loan_apps':      ['application_date', 'disbursement_date'],
    'loan_payments':  ['due_date', 'payment_date'],
    'transactions':   ['transaction_date'],
}

for tbl_name, cols in date_columns.items():
    df = all_tables[tbl_name]
    for col in cols:
        if col in df.columns:
            before_dtype = str(df[col].dtype)
            df[col] = pd.to_datetime(df[col], errors='coerce')
            invalid_dates = df[col].isna().sum()
            print(f"  ✔ {tbl_name}.{col}: {before_dtype} → datetime64"
                  f"  (invalid/coerced: {invalid_dates:,})")

print("\n  ✅ All date columns converted!")


# ============================================================
# 6. CATEGORICAL COLUMN STANDARDIZATION
# ============================================================

print("\n\n" + "=" * 65)
print("🏷️  Step 6: Categorical Column Standardization")
print("=" * 65)

# Print unique value counts for key categorical columns
categorical_checks = {
    'customers': ['gender', 'marital_status', 'education', 'employment_type',
                  'account_type', 'kyc_status', 'customer_segment', 'zone'],
    'employees': ['gender', 'designation', 'department'],
    'branches':  ['branch_type', 'zone'],
    'credit_history': ['credit_rating'],
    'loan_apps': ['status', 'loan_type_name'],
    'loan_payments': ['payment_status'],
    'transactions': ['transaction_type', 'transaction_mode', 'category', 'status'],
}

for tbl_name, cols in categorical_checks.items():
    df = all_tables[tbl_name]
    print(f"\n  📌 {tbl_name.upper()}")
    for col in cols:
        if col in df.columns:
            uniques = df[col].nunique()
            vals = df[col].value_counts().head(8).to_dict()
            vals_str = ', '.join([f"{k}: {v:,}" for k, v in vals.items()])
            print(f"     {col} ({uniques} unique): {vals_str}")

# ── Strip whitespace from all string/object columns ──
print("\n\n  🔧 Stripping whitespace from all text columns...")
for name, df in all_tables.items():
    for col in df.select_dtypes(include='object').columns:
        df[col] = df[col].str.strip()
print("  ✅ Whitespace stripped!")

# ── Standardize case for key columns ──
print("  🔧 Standardizing case (Title Case) for key columns...")
title_case_cols = {
    'customers': ['gender', 'marital_status', 'education', 'employment_type',
                  'account_type', 'kyc_status', 'customer_segment'],
    'employees': ['gender', 'designation', 'department'],
    'branches':  ['branch_type'],
    'credit_history': ['credit_rating'],
    'loan_apps': ['status'],
    'loan_payments': ['payment_status'],
    'transactions': ['transaction_type', 'transaction_mode', 'status'],
}

for tbl_name, cols in title_case_cols.items():
    df = all_tables[tbl_name]
    for col in cols:
        if col in df.columns:
            df[col] = df[col].astype(str).str.strip().str.title()

print("  ✅ Case standardization complete!")


# ============================================================
# 7. NUMERICAL OUTLIER DETECTION (IQR Method)
# ============================================================

print("\n\n" + "=" * 65)
print("📊 Step 7: Numerical Outlier Detection (IQR Method)")
print("=" * 65)

outlier_columns = {
    'customers':      ['annual_income', 'age'],
    'credit_history': ['credit_score', 'total_outstanding_debt',
                       'credit_utilization_pct', 'number_of_delinquencies'],
    'loan_apps':      ['loan_amount_requested', 'loan_amount_approved',
                       'tenure_months', 'interest_rate_pct'],
    'loan_payments':  ['emi_amount', 'penalty_amount', 'days_late',
                       'outstanding_balance'],
    'transactions':   ['amount'],
}


def detect_outliers_iqr(series, factor=1.5):
    """Detect outliers using IQR method and return count + bounds."""
    Q1 = series.quantile(0.25)
    Q3 = series.quantile(0.75)
    IQR = Q3 - Q1
    lower = Q1 - factor * IQR
    upper = Q3 + factor * IQR
    outliers = ((series < lower) | (series > upper)).sum()
    return outliers, lower, upper, Q1, Q3


print(f"\n  {'Table':<18} {'Column':<28} {'Outliers':>9} {'%':>7} "
      f"{'Q1':>12} {'Q3':>12} {'Lower':>12} {'Upper':>12}")
print(f"  {'─' * 113}")

for tbl_name, cols in outlier_columns.items():
    df = all_tables[tbl_name]
    for col in cols:
        if col in df.columns:
            valid = df[col].dropna()
            if len(valid) == 0:
                continue
            outliers, lower, upper, q1, q3 = detect_outliers_iqr(valid)
            pct = (outliers / len(valid) * 100)
            print(f"  {tbl_name:<18} {col:<28} {outliers:>9,} {pct:>6.2f}% "
                  f"{q1:>12,.2f} {q3:>12,.2f} {lower:>12,.2f} {upper:>12,.2f}")

print("\n  ℹ️  Note: Outliers are flagged for awareness — NOT removed.")
print("      Banking data often has legitimate extreme values (high-value loans, etc.)")


# ============================================================
# 8. FEATURE ENGINEERING (Derived Columns)
# ============================================================

print("\n\n" + "=" * 65)
print("⚙️  Step 8: Feature Engineering — Derived Columns")
print("=" * 65)

# ── 8a. Customers ──
print("\n  📌 CUSTOMERS")

# Age group
bins_age = [0, 25, 35, 45, 55, 65, 120]
labels_age = ['18-25', '26-35', '36-45', '46-55', '56-65', '65+']
customers['age_group'] = pd.cut(customers['age'], bins=bins_age, labels=labels_age)
print("     ✔ age_group: 18-25, 26-35, 36-45, 46-55, 56-65, 65+")

# Income bracket
bins_income = [0, 200000, 500000, 1000000, 2000000, float('inf')]
labels_income = ['<2L', '2-5L', '5-10L', '10-20L', '20L+']
customers['income_bracket'] = pd.cut(customers['annual_income'],
                                      bins=bins_income, labels=labels_income)
print("     ✔ income_bracket: <2L, 2-5L, 5-10L, 10-20L, 20L+")

# Account tenure in years
customers['account_tenure_years'] = (
    (pd.Timestamp.now() - customers['account_open_date']).dt.days / 365.25
).round(1)
print("     ✔ account_tenure_years")


# ── 8b. Credit History ──
print("\n  📌 CREDIT_HISTORY")

# Credit score band
bins_credit = [0, 600, 700, 800, 900]
labels_credit = ['Poor (<600)', 'Fair (600-699)', 'Good (700-799)', 'Excellent (800+)']
credit_history['credit_band'] = pd.cut(credit_history['credit_score'],
                                        bins=bins_credit, labels=labels_credit)
print("     ✔ credit_band: Poor, Fair, Good, Excellent")

# Debt-to-utilization flag
credit_history['high_utilization'] = (
    credit_history['credit_utilization_pct'] > 75
).astype(int)
print("     ✔ high_utilization: 1 if utilization > 75%")


# ── 8c. Loan Applications ──
print("\n  📌 LOAN_APPLICATIONS")

# Approval flag
loan_apps['is_approved'] = loan_apps['status'].isin(
    ['Disbursed', 'Approved', 'Closed']
).astype(int)
print("     ✔ is_approved: 1 for Disbursed/Approved/Closed")

# Amount gap (requested - approved)
loan_apps['amount_gap'] = (
    loan_apps['loan_amount_requested'] - loan_apps['loan_amount_approved']
)
loan_apps['gap_pct'] = (
    loan_apps['amount_gap'] / loan_apps['loan_amount_requested'] * 100
).round(2)
print("     ✔ amount_gap & gap_pct: Difference between requested and approved")

# Application year & month
loan_apps['app_year'] = loan_apps['application_date'].dt.year
loan_apps['app_month'] = loan_apps['application_date'].dt.month
loan_apps['app_quarter'] = loan_apps['application_date'].dt.quarter
print("     ✔ app_year, app_month, app_quarter")


# ── 8d. Loan Payments ──
print("\n  📌 LOAN_PAYMENTS")

# Late payment flag
loan_payments['is_late'] = (loan_payments['days_late'] > 0).astype(int)
print("     ✔ is_late: 1 if days_late > 0")

# Missed payment flag
loan_payments['is_missed'] = (
    loan_payments['payment_status'].str.lower() == 'missed'
).astype(int)
print("     ✔ is_missed: 1 if payment_status = Missed")

# Payment month
loan_payments['pay_year'] = loan_payments['due_date'].dt.year
loan_payments['pay_month'] = loan_payments['due_date'].dt.month
print("     ✔ pay_year, pay_month")


# ── 8e. Transactions ──
print("\n  📌 TRANSACTIONS")

# Transaction year, month, day_of_week
transactions['txn_year'] = transactions['transaction_date'].dt.year
transactions['txn_month'] = transactions['transaction_date'].dt.month
transactions['txn_day_of_week'] = transactions['transaction_date'].dt.day_name()
transactions['txn_hour'] = transactions['transaction_date'].dt.hour
print("     ✔ txn_year, txn_month, txn_day_of_week, txn_hour")

# Amount bucket
bins_txn = [0, 500, 2000, 10000, 50000, float('inf')]
labels_txn = ['Micro (<500)', 'Small (500-2K)', 'Medium (2K-10K)',
              'Large (10K-50K)', 'High Value (50K+)']
transactions['amount_bucket'] = pd.cut(transactions['amount'],
                                        bins=bins_txn, labels=labels_txn)
print("     ✔ amount_bucket: Micro, Small, Medium, Large, High Value")

print("\n  ✅ Feature engineering complete!")


# ============================================================
# 9. FINAL SUMMARY & DATA EXPORT
# ============================================================

print("\n\n" + "=" * 65)
print("💾 Step 9: Final Summary & Cleaned Data Export")
print("=" * 65)

# Update the all_tables dict with cleaned data
all_tables.update({
    'customers': customers,
    'credit_history': credit_history,
    'loan_apps': loan_apps,
    'loan_payments': loan_payments,
    'transactions': transactions,
})

print(f"\n  {'Table':<20} {'Rows':>10} {'Columns':>8} {'New Cols':>10}")
print(f"  {'─' * 50}")

original_cols = {
    'regions': 6, 'loan_types': 11, 'branches': 11, 'employees': 16,
    'customers': 29, 'credit_history': 12, 'loan_apps': 20,
    'loan_payments': 13, 'transactions': 13,
}

for name, df in all_tables.items():
    new_cols = df.shape[1] - original_cols.get(name, df.shape[1])
    new_str = f"+{new_cols}" if new_cols > 0 else "—"
    print(f"  {name:<20} {df.shape[0]:>10,} {df.shape[1]:>8} {new_str:>10}")

# ── Export cleaned CSVs ──
print(f"\n  📁 Exporting cleaned data to: {CLEAN_PATH}")
for name, df in all_tables.items():
    filepath = os.path.join(CLEAN_PATH, f"{name}_cleaned.csv")
    df.to_csv(filepath, index=False)
    size_mb = os.path.getsize(filepath) / (1024 ** 2)
    print(f"     ✔ {name}_cleaned.csv ({size_mb:.2f} MB)")


# ============================================================
# PREPROCESSING COMPLETE
# ============================================================

print("\n\n" + "=" * 65)
print("  ✅ PREPROCESSING PIPELINE COMPLETE!")
print("=" * 65)
print("""
  Summary of Steps Performed:
  ─────────────────────────────────────────────
  1. ✔ Data Loading & Shape Overview
  2. ✔ Data Types & Column Summary
  3. ✔ Missing Value Analysis & Handling
  4. ✔ Duplicate Detection & Removal
  5. ✔ Date Column Conversion (str → datetime)
  6. ✔ Categorical Standardization (strip + title case)
  7. ✔ Numerical Outlier Detection (IQR method)
  8. ✔ Feature Engineering (13+ derived columns)
  9. ✔ Cleaned Data Exported to CSV
  ─────────────────────────────────────────────

  Next Step → Run eda_plotly.py for visualizations!
""")
