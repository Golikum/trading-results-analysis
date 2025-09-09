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

### dbt Tests
Our data quality framework includes various test types:

1. **Uniqueness Tests**:
   - Trade identifiers (`trade_id` in `fact_trades`)
   - Composite keys (`account_id || '_' || date` in `fact_account_eod`)
   - Performance rankings (`performance_rank` in `mart_client_performance_ranking`)

2. **Range Validations**:
   - Trading volumes (must be positive)
   - Drawdown ratios (between -100% and 0%)
   - Trading frequency (0 to 1 range)
   - Performance metrics (minimum thresholds)

3. **Category Validations**:
   - Client segments (Retail, Pro, VIP)
   - Performance categories (Profitable, Break-even, Loss-making)
   - Trading intensity (High/Medium/Low Volume)

4. **Relationship Checks**:
   - Account references across fact tables
   - Client linkage through dimensions
   - Symbol standardization validation

Example test configurations:
```yaml
version: 2

models:
  - name: mart_client_performance_ranking
    columns:
      - name: client_id
        tests:
          - unique
          - not_null
      - name: performance_category
        tests:
          - accepted_values:
              values: ['Profitable', 'Break-even', 'Loss-making']
      - name: trading_frequency_pct
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1
              inclusive: true

  - name: fact_trades
    columns:
      - name: trade_id
        tests:
          - unique
          - not_null
      - name: volume
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: false
      - name: segment
        tests:
          - accepted_values:
              values: ['Retail', 'Pro', 'VIP', 'Unknown']

  - name: mart_segment_trade_size_analysis
    columns:
      - name: segment
        tests:
          - unique
          - not_null
      - name: trading_intensity
        tests:
          - accepted_values:
              values: ['High Volume', 'Medium Volume', 'Low Volume']
      - name: avg_trades_per_day
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              inclusive: false
```

