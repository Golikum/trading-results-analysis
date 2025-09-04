# BigQuery Command Line Upload Script
# Install gcloud CLI first: https://cloud.google.com/sdk/docs/install
# Run: gcloud auth login
# Run: gcloud config set project dbt-learn-366003

# Upload trades_raw.csv
bq load \
    --source_format=CSV \
    --skip_leading_rows=1 \
    --autodetect \
    dbt-learn-366003:trading_raw_data.trades_raw \
    trades_raw.csv

# Upload accounts_raw.csv
bq load \
    --source_format=CSV \
    --skip_leading_rows=1 \
    --autodetect \
    dbt-learn-366003:trading_raw_data.accounts_raw \
    accounts_raw.csv

# Upload clients_raw.csv
bq load \
    --source_format=CSV \
    --skip_leading_rows=1 \
    --autodetect \
    dbt-learn-366003:trading_raw_data.clients_raw \
    clients_raw.csv

# Upload balances_eod_raw.csv
bq load \
    --source_format=CSV \
    --skip_leading_rows=1 \
    --autodetect \
    dbt-learn-366003:trading_raw_data.balances_eod_raw \
    balances_eod_raw.csv

# Upload symbols_ref.csv
bq load \
    --source_format=CSV \
    --skip_leading_rows=1 \
    --autodetect \
    dbt-learn-366003:trading_raw_data.symbols_ref \
    symbols_ref.csv

# Verify uploads
bq query --use_legacy_sql=false \
"SELECT table_name, row_count 
 FROM \`dbt-learn-366003.trading_raw_data.INFORMATION_SCHEMA.TABLES\` 
 WHERE table_type = 'BASE_TABLE' 
 ORDER BY table_name"
