import pandas as pd
import seaborn as sns
import duckdb

duck_db_conn_str = '../duckdb/dev_db.duckdb'
con = duckdb.connect(duck_db_conn_str)
sql_query_tab = """
    SELECT
        *
    FROM main.weather_and_sales
"""
df = con.query(sql_query_tab).df()



# Number of orders related to the average temperature?
sns.lmplot(
    data=df, x="temperature_avg", y="cnt_distinct_orders"
    ,col="sales_territory_key"
)

# Average Sales per day related to the average temperature?
p = sns.lmplot(
    data=df, x="temperature_avg", y="avg_sales_dollar"
    ,col="sales_territory_key"
)
p.savefig('avg_sales_dollar_vs_temperature_avg.png', dpi=200)