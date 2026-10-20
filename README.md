# NYC Taxi Insights

Production-style analytics engineering project built with **dbt** and **BigQuery** using the public NYC TLC taxi datasets.

## Architecture

The project follows a layered warehouse design:

1. **Sources** - BigQuery public Yellow Taxi, Green Taxi, and taxi-zone tables.
2. **Staging** - Yearly tables are unioned and lightly normalized without changing business meaning.
3. **Intermediate** - Yellow and Green trips are combined, deduplicated, validated, and enriched with derived fields.
4. **Core** - Analytics-ready fact and dimension models for reporting and downstream consumption.

All models are documented and tested. Core models are materialized as tables, while staging and intermediate models remain views to keep development inexpensive.

## Prerequisites

- Python 3.10+
- dbt Core with the BigQuery adapter
- A Google Cloud project with BigQuery enabled
- Application Default Credentials or a service-account key with permission to create datasets and query BigQuery

Install dependencies:

```bash
python -m pip install dbt-bigquery
dbt deps
```

Create a dbt profile named `nyc_taxi_project` in `~/.dbt/profiles.yml`:

```yaml
nyc_taxi_project:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: your-gcp-project
      dataset: nyc_taxi_dev
      threads: 4
      location: US
      priority: interactive
```

## Development commands

```bash
dbt debug
dbt deps
dbt seed
dbt build
dbt source freshness
dbt docs generate
dbt docs serve
```

`dbt build` runs models and their associated data-quality tests in dependency order. Use selectors such as `dbt build --select staging` or `dbt build --select +fact_trips` while iterating.

## Engineering practices

- Keep source ingestion and business logic separate.
- Add model and column documentation with every new model.
- Add uniqueness, nullability, accepted-value, and relationship tests where they express a real invariant.
- Use incremental models for high-volume production tables once the deployment target is configured.
- Store credentials in the environment or a secret manager; never commit `profiles.yml` or service-account keys.

## Roadmap

- Add incremental partitioned BigQuery fact tables.
- Add a scheduled ingestion layer for new TLC files.
- Add CI for `dbt deps`, `dbt parse`, and changed-model builds.
- Configure source freshness checks after an ingestion timestamp is available.
- Add exposures for dashboards and business-facing metrics.
- Add observability for freshness, test failures, and warehouse cost.
