/* @bruin
name: bronze.system_metrics
type: duckdb.sql
connection: duckdb-default

materialization:
  type: table
@bruin */

select *
from read_csv(
    'system_metrics/metrics.csv',
    header = true,
    columns = {
        'ts': 'TIMESTAMP',
        'source': 'VARCHAR',
        'metric': 'VARCHAR',
        'value': 'BIGINT'
    }
)
