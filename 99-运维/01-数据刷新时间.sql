WITH cte_res AS
(
	SELECT  'POS日报'                          AS dashboard_name
	       ,'tb_pos_sales_calendar_flat_qbi' AS table_name
	       ,MAX(created_dt)                  AS created_dt
	       ,MAX(report_date)                 AS report_date
	FROM edw_cl7733.tb_pos_sales_calendar_flat_qbi
	WHERE dt >= '20250201' 
	UNION ALL
	SELECT  'POS日报-农历'                    AS dashboard_name
	       ,'tb_pos_sales_lunar_flat_qbi' AS table_name
	       ,MAX(created_dt)               AS created_dt
	       ,MAX(report_date)              AS report_date
	FROM edw_cl7733.tb_pos_sales_lunar_flat_qbi
	WHERE dt >= '20250201' 
)
SELECT  *
       ,CURRENT_DATE()                                                                   AS today
       ,cast(to_date(substring(created_dt,1,10),'yyyy-mm-dd') AS date) >= CURRENT_DATE() AS flag
FROM cte_res



select
  report_date,
  sum(pieces),
  max(created_dt)
from
  tb_pos_sales_daily_fact
where report_date >= '20250224'
group by report_date
order by report_date