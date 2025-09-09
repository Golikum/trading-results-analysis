# Trading Results Analysis 📊

Analytics Engineering challenge: Transform raw trading data into clean, analysis-ready marts and deliver insights on trader performance, activity, and risk.

## 📊 Interactive Dashboard
View the full analysis in our [Looker Studio Dashboard](https://lookerstudio.google.com/s/mdZfMruL_io)

## 🏗️ Architecture

```
CSV Files → BigQuery (Free Tier) → dbt Cloud (Free Tier) → Looker Studio (Free) → GitHub
```

## 🎯 Business Questions

This project answers critical questions for brokerage leadership:

- **Performance**: Who are the top performers and underperformers?
- **Activity**: How many traders are active and what are their trading patterns?
- **Risk**: Which clients/accounts are at risk or showing concerning patterns?

## 📁 Data Sources

| File | Description | Key Fields |
|------|-------------|------------|
| `trades_raw.csv` | Individual trade records | trade_id, account_id, symbol, side, volume, pnl |
| `accounts_raw.csv` | Trading account registry | account_id, client_id, platform, base_currency |
| `clients_raw.csv` | Client master data | client_id, jurisdiction, segment |
| `balances_eod_raw.csv` | End-of-day account balances | account_id, date, balance, equity, margin_level |
| `symbols_ref.csv` | Symbol normalization reference | platform_symbol, std_symbol, asset_class |


## 🏗️ Project Structure

```
trading-results-analysis/
├── models/
│   ├── staging/          # Clean and standardize raw data
│   │   ├── stg_accounts.sql         # Account data cleaning
│   │   ├── stg_balances_eod.sql     # EOD balance standardization
│   │   ├── stg_clients.sql          # Client data normalization
│   │   ├── stg_symbols_ref.sql      # Symbol reference mapping
│   │   └── stg_trades.sql           # Trade data transformation
│   ├── dimensions/       # Core business entities
│   │   ├── dim_account.sql          # Account master data
│   │   ├── dim_client.sql           # Client profiles and segments
│   │   └── dim_symbol.sql           # Standardized trading instruments
│   ├── facts/           # Transaction and event data
│   │   ├── fact_account_eod.sql     # Daily account metrics
│   │   ├── fact_client_performance_daily.sql  # Client daily performance
│   │   └── fact_trades.sql          # Cleaned trade records
│   └── marts/           # Business-specific analytics
│       ├── mart_account_drawdown_analysis.sql    # Account risk metrics
│       ├── mart_accounts_at_risk.sql            # Risk monitoring
│       ├── mart_client_drawdown_analysis.sql     # Client risk assessment
│       ├── mart_client_performance_ranking.sql   # Performance rankings
│       ├── mart_daily_client_account_activity.sql # Activity tracking
│       ├── mart_segment_trade_size_analysis.sql  # Trading patterns
│       └── mart_symbol_performance_ranking.sql   # Symbol analytics
└── macros/              # Reusable SQL functions
```

## 📊 Data Model

### Model Layers

**Staging**: Clean and standardize raw data from source files, handling data quality issues and standardizing formats.

**Dimensions**: Core reference data that provides context for analysis:
- Client profiles with segments and jurisdictions
- Account details with platform and status information
- Standardized symbol reference with asset classes

**Facts**: Transaction and event data:
- Trade records with performance metrics
- Daily account balance snapshots
- Aggregated client daily performance

**Marts**: Business-specific analytics models:
- Performance rankings (client and symbol level)
- Risk monitoring and drawdown analysis
- Trading activity patterns and segment analysis

## 📈 Key Metrics & KPIs

### Activity Metrics
- **Active Traders Tracking**:
  - Daily active clients and accounts count
  - Weekly active clients and accounts count
- **Average Trade Size Analysis**:
  - By symbol (volume, trade value, risk amount)
  - By client segment (VIP, Retail, Pro)
  - Risk exposure

### Risk Assessment
- **Drawdown Analysis**:
  - Account-level equity drawdown (current vs high water mark, ratio)
  - Client-level equity drawdown
  - Largest drawdowns monitoring
- **Account Health**:
  - Deleted accounts still trading
  - Number of trades in deleted accounts
  - Client risk exposure

### Performance Metrics
- **Client Level Performance**:
  - Net PnL ranking (Top/Bottom 10 performers)
- **Symbol Level Performance**:
  - Net PnL by symbol (Top/Bottom 10 performers)


## 📋 Data Quality Framework

### dbt Tests (examples)
```yaml
version: 2

models:
  - name: fact_trades
    columns:
      - name: trade_id
        tests:
          - unique
          - not_null
      - name: segment
        tests:
          - not_null
          - accepted_values:
              values: ['Retail', 'Pro', 'VIP', 'Unknown']
      - name: volume
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: false
  
  - name: fact_account_eod
    tests:
      - unique:
          column_name: "account_id || '_' || date"
    columns:
      - name: margin_level
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: true
  
  - name: mart_client_performance_ranking
    columns:
      - name: performance_category
        tests:
          - accepted_values:
              values: ['Profitable', 'Break-even', 'Loss-making']
      - name: total_trades
        tests:
          - dbt_utils.accepted_range:
              min_value: 1
              inclusive: true
```

The tests ensure data quality through:
- Uniqueness checks (trade_id, composite keys)
- Required field validation (not_null)
- Value range validation (volumes, trades, margin levels)
- Business category validation (segments, performance)

