# Trading Results Analysis 📊

Analytics Engineering challenge: Transform raw trading data into clean, analysis-ready marts and deliver insights on trader performance, activity, and risk.

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

## 🚀 Setup Instructions

### Prerequisites

1. **Google Cloud Project** with BigQuery API enabled
2. **dbt Cloud account** (free tier)
3. **GitHub account** for version control

### Step 1: BigQuery Setup

1. Create a new Google Cloud Project or use existing one
2. Enable BigQuery API
3. Create datasets:
   ```sql
   -- In BigQuery console
   CREATE SCHEMA `your-project-id.raw_data`;
   CREATE SCHEMA `your-project-id.staging`;
   CREATE SCHEMA `your-project-id.marts`;
   ```
4. Upload CSV files to `raw_data` dataset
5. Create a service account and download JSON key for dbt Cloud

### Step 2: dbt Cloud Setup

1. **Create New Project** in dbt Cloud
2. **Connect to Repository**: Link this GitHub repository
3. **Configure BigQuery Connection**:
   - Upload service account JSON
   - Set project ID and datasets
   - Test connection
4. **Update `models/sources.yml`**: Replace `your-gcp-project-id` with your actual project ID

### Step 3: Install Dependencies

```bash
# In dbt Cloud IDE or locally
dbt deps
```

### Step 4: Run the Project

```bash
# Test source data
dbt source snapshot-freshness

# Run staging models
dbt run --models staging

# Run all models
dbt run

# Run tests
dbt test
```

## 🏗️ Project Structure

```
trading-results-analysis/
├── models/
│   ├── staging/          # Clean and standardize raw data
│   ├── intermediate/     # Business logic and enrichment
│   └── marts/           # Final dimensional model
│       ├── dimensions/  # Dimension tables
│       └── facts/       # Fact tables
├── tests/               # Custom data quality tests
├── macros/              # Reusable SQL functions
├── analyses/            # Ad-hoc analysis queries
├── snapshots/           # SCD2 snapshots
└── seeds/              # Static reference data
```

## 📊 Data Model

### Staging Layer
- `stg_trades` - Cleaned trade data
- `stg_accounts` - Validated account information
- `stg_clients` - Normalized client data
- `stg_balances_eod` - Clean balance data
- `stg_symbols_ref` - Symbol standardization

### Marts Layer
**Dimensions**:
- `dim_clients` - Client master with segments and jurisdictions
- `dim_accounts` - Account details with platform and currency info
- `dim_symbols` - Normalized symbol reference with asset classes
- `dim_dates` - Date dimension for time-based analysis

**Facts**:
- `fact_trades` - Granular trade transactions with performance metrics
- `fact_account_eod` - Daily account balances and equity positions
- `fact_client_performance_daily` - Aggregated daily client performance

## 📈 Key Metrics & KPIs

- **Net PnL**: `realized_pnl + commission`
- **Active Traders**: Clients/accounts with trades in period
- **Equity Drawdown**: Peak-to-trough equity decline
- **Risk Indicators**: Deleted accounts still trading, low margin levels

## 🔧 Development Workflow

1. **Feature Branch**: Create branch for new features
2. **Development**: Build and test models in dbt Cloud IDE
3. **Testing**: Ensure all tests pass (`dbt test`)
4. **Pull Request**: Submit for code review
5. **Merge**: Deploy to production

## 📋 Data Quality Framework

- **Uniqueness**: Primary key constraints
- **Referential Integrity**: Foreign key relationships
- **Business Logic**: Net PnL calculations
- **Completeness**: Required field validation
- **Accepted Values**: Categorical field validation

## 🔗 Next Steps

1. **Connect dbt Cloud** to this repository
2. **Upload CSV data** to BigQuery raw dataset
3. **Configure BigQuery connection** in dbt Cloud
4. **Run initial models** and validate data quality
5. **Build Looker Studio dashboard** for insights
6. **Document findings** and recommendations

---

*Built with ❤️ using modern data stack: dbt + BigQuery + Looker Studio*
