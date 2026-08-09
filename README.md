# Elementary Tutorial

Welcome to the Elementary tutorial! This project demonstrates how to use Elementary for data observability with dbt.

<!-- Test comment for PR functionality -->

## Getting Started

This tutorial will walk you through:

1. Setting up Elementary in your dbt project
2. Adding data quality tests
3. Viewing results in the Elementary UI
4. Setting up alerts and monitoring

## Prerequisites

- Python 3.7+
- dbt Core or dbt Cloud
- A supported data warehouse (Snowflake, BigQuery, Redshift, etc.)

## Installation

1. Install Elementary:
```bash
pip install elementary-data
```

2. Add Elementary to your `packages.yml`:
```yaml
packages:
  - package: elementary-data/elementary
    version: 0.15.1
```

3. Run `dbt deps` to install the package

4. Add Elementary models to your `dbt_project.yml`:
```yaml
models:
  elementary:
    +materialized: view
    +schema: elementary
```

## Usage

1. Run your dbt models with Elementary tests:
```bash
dbt run
dbt test
```

2. Generate the Elementary report:
```bash
edr report
```

3. Send results to Elementary Cloud (optional):
```bash
edr send-report
```

## Learn More

- [Elementary Documentation](https://docs.elementary-data.com/)
- [Elementary GitHub](https://github.com/elementary-data/elementary)
- [Elementary Community Slack](https://join.slack.com/t/elementary-community/shared_invite/zt-uehfrq2f-zXeVTtXrjYRbdE_V6xq4Rg)
