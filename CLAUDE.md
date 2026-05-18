# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A dbt project targeting **BigQuery** built on the [Jaffle Shop](https://github.com/dbt-labs/jaffle-shop) dataset. Seeds provide the raw layer; the workshop goal is to build staging, intermediate, and mart models that answer a defined analytics question.

- dbt project name: `university_workshop`
- Profile name (must match `~/.dbt/profiles.yml`): `university_workshop`
- Seeds land in: `<your_dataset>_raw` dataset on BigQuery

## Common commands

```bash
# Validate connection and config
dbt debug

# Load seed CSVs into BigQuery raw dataset
dbt seed

# Build all models
dbt build

# Build a single model (and its upstream deps)
dbt build --select stg_orders+

# Run models only (skip tests)
dbt run

# Run tests only
dbt test

# Test a single model
dbt test --select stg_orders

# Compile SQL without running
dbt compile

# List all models/resources
dbt ls

# Parse project for syntax errors
dbt parse
```

## Architecture and layer conventions

Models live in `models/` and follow a strict three-layer pattern:

```
seeds/          → raw_* tables (source of truth, CSVs loaded by dbt seed)
models/staging/ → stg_* (1-to-1 with seeds, rename + cast only)
models/intermediate/ → int_* (reusable joins, business logic)
models/marts/   → dim_* and fct_* (final analytics-facing models)
```

### Staging layer (`models/staging/`)
- One model per seed table, named `stg_<entity>.sql`
- Pattern: `source` CTE → `renamed` CTE → `select * from renamed`
- Source reference: `{{ source('jaffle_shop', 'raw_<entity>') }}`
- Only rename fields and cast types here; no joins or business logic
- Use `SAFE_CAST(... AS NUMERIC)` and `TIMESTAMP(...)` for BigQuery

### Source definitions
`models/staging/_sources.yml` declares the `jaffle_shop` source pointing at `jaffle-shop-496200.raw_raw`. All staging models must reference seeds via `{{ source('jaffle_shop', 'raw_*') }}`.

### Seed schema (join map)
- `raw_orders.customer` → `raw_customers.id`
- `raw_orders.store_id` → `raw_stores.id`
- `raw_items.order_id` → `raw_orders.id`
- `raw_items.sku` → `raw_products.sku`
- `raw_supplies.sku` → `raw_products.sku`

## Packages

- `dbt-labs/dbt_utils` (≥1.3.0) — general SQL utilities
- `dbt-labs/codegen` (0.14.1) — auto-generate model/source YAML; useful for bootstrapping schema files

Install/update: `dbt deps`

## Static analysis

`dbt_project.yml` sets `+static_analysis: strict` for all models — dbt Fusion will enforce stricter SQL linting at compile time.

## Testing and documentation conventions

- Every primary key column should have `unique` and `not_null` tests in a `schema.yml` alongside its model
- Add at least one business-logic test per mart (e.g., `accepted_values`, `relationships`, or a custom test)
- Add `description:` to each model and its key columns in `schema.yml`
