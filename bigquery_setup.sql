-- BigQuery Setup Script for Trading Results Analysis
-- Run these commands in BigQuery Console (https://console.cloud.google.com/bigquery)
-- Project: dbt-learn-366003

-- 1. Create Raw Data Dataset (for CSV uploads)
CREATE SCHEMA `dbt-learn-366003.trading_raw_data`
OPTIONS(
  description="Raw trading data from CSV exports - immutable source layer",
  location="US"
);

-- 2. Create Staging Dataset (for cleaned/standardized data)
CREATE SCHEMA `dbt-learn-366003.trading_staging`
OPTIONS(
  description="Staging layer - cleaned and standardized trading data",
  location="US"
);

-- 3. Create Marts Dataset (for final business-ready models)
CREATE SCHEMA `dbt-learn-366003.trading_marts`
OPTIONS(
  description="Business marts - dimensional model for analysis and reporting",
  location="US"
);

-- Verify datasets were created
SELECT 
  schema_name,
  location,
  creation_time
FROM `dbt-learn-366003.INFORMATION_SCHEMA.SCHEMATA`
WHERE schema_name IN ('trading_raw_data', 'trading_staging', 'trading_marts')
ORDER BY schema_name;
