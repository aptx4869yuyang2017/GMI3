WITH cte_res AS
(
	SELECT  '销售总览-01OverviewKPI' AS dashboard_name -- , 'vw_sellin_demand_accuracy_flat_qbi' AS table_name
	       ,MAX(created_dt)                                                                        AS created_dt
	       ,MAX(fiscal_year || fiscal_month)                                                       AS report_date
	FROM edw_cl7733_dev.vw_sellin_demand_accuracy_flat_qbi
)
SELECT  *
       ,CURRENT_DATE()                                                                   AS today
       ,cast(to_date(substring(created_dt,1,10),'yyyy-mm-dd') AS date) >= CURRENT_DATE() AS flag
FROM cte_res