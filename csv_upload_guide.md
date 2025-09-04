# CSV Upload Guide - BigQuery

## Upload Settings for Each CSV File

### 1. trades_raw.csv
**Create table settings:**
- Source: Upload
- Select file: `trades_raw.csv`
- File format: CSV
- Project: `dbt-learn-366003`
- Dataset: `trading_raw_data`
- Table: `trades_raw`
- Schema: Auto detect ✅
- Header rows to skip: 1
- Allow jagged rows: ✅
- Allow quoted newlines: ✅

### 2. accounts_raw.csv
**Create table settings:**
- Source: Upload
- Select file: `accounts_raw.csv`
- File format: CSV
- Project: `dbt-learn-366003`
- Dataset: `trading_raw_data`
- Table: `accounts_raw`
- Schema: Auto detect ✅
- Header rows to skip: 1
- Allow jagged rows: ✅
- Allow quoted newlines: ✅

### 3. clients_raw.csv
**Create table settings:**
- Source: Upload
- Select file: `clients_raw.csv`
- File format: CSV
- Project: `dbt-learn-366003`
- Dataset: `trading_raw_data`
- Table: `clients_raw`
- Schema: Auto detect ✅
- Header rows to skip: 1
- Allow jagged rows: ✅
- Allow quoted newlines: ✅

### 4. balances_eod_raw.csv
**Create table settings:**
- Source: Upload
- Select file: `balances_eod_raw.csv`
- File format: CSV
- Project: `dbt-learn-366003`
- Dataset: `trading_raw_data`
- Table: `balances_eod_raw`
- Schema: Auto detect ✅
- Header rows to skip: 1
- Allow jagged rows: ✅
- Allow quoted newlines: ✅

### 5. symbols_ref.csv
**Create table settings:**
- Source: Upload
- Select file: `symbols_ref.csv`
- File format: CSV
- Project: `dbt-learn-366003`
- Dataset: `trading_raw_data`
- Table: `symbols_ref`
- Schema: Auto detect ✅
- Header rows to skip: 1
- Allow jagged rows: ✅
- Allow quoted newlines: ✅

## 🔍 After Upload - Verification Queries

Run these queries to verify your data loaded correctly:

```sql
-- Check all tables were created
SELECT 
  table_name,
  row_count,
  size_bytes
FROM `dbt-learn-366003.trading_raw_data.INFORMATION_SCHEMA.TABLES`
WHERE table_type = 'BASE TABLE'
ORDER BY table_name;

-- Preview each table (first 5 rows)
SELECT 'trades_raw' as table_name, COUNT(*) as row_count FROM `dbt-learn-366003.trading_raw_data.trades_raw`
UNION ALL
SELECT 'accounts_raw', COUNT(*) FROM `dbt-learn-366003.trading_raw_data.accounts_raw`
UNION ALL
SELECT 'clients_raw', COUNT(*) FROM `dbt-learn-366003.trading_raw_data.clients_raw`
UNION ALL
SELECT 'balances_eod_raw', COUNT(*) FROM `dbt-learn-366003.trading_raw_data.balances_eod_raw`
UNION ALL
SELECT 'symbols_ref', COUNT(*) FROM `dbt-learn-366003.trading_raw_data.symbols_ref`
ORDER BY table_name;
```

## 📊 Sample Data Preview

After upload, run these to see your data:

```sql
-- Preview trades data
SELECT * FROM `dbt-learn-366003.trading_raw_data.trades_raw` LIMIT 5;

-- Preview accounts data  
SELECT * FROM `dbt-learn-366003.trading_raw_data.accounts_raw` LIMIT 5;

-- Preview clients data
SELECT * FROM `dbt-learn-366003.trading_raw_data.clients_raw` LIMIT 5;

-- Preview balances data
SELECT * FROM `dbt-learn-366003.trading_raw_data.balances_eod_raw` LIMIT 5;

-- Preview symbols reference
SELECT * FROM `dbt-learn-366003.trading_raw_data.symbols_ref` LIMIT 5;
```

## 🚨 Common Issues & Solutions

**Problem**: Schema auto-detect fails
**Solution**: Manually define schema with these common data types:
- `trade_id`: STRING
- `account_id`: STRING  
- `volume`: FLOAT64
- `realized_pnl`: FLOAT64
- `commission`: FLOAT64
- `open_time`: TIMESTAMP
- `close_time`: TIMESTAMP
- `date`: DATE

**Problem**: Upload fails due to file size
**Solution**: Use `bq` command line tool or Google Cloud Storage staging

**Problem**: Encoding issues
**Solution**: Ensure CSV files are UTF-8 encoded
