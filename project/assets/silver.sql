/* @bruin
name: silver.system_metrics
type: duckdb.sql
connection: duckdb-default

depends:
  - bronze.system_metrics

materialization:
  type: table
@bruin */

select source, count(*) as metric_count
from bronze.system_metrics
group by source
