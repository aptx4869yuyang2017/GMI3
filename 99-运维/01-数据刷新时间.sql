WITH cte_res AS
(
	SELECT  'P3-POS日报'                       AS dashboard_name
	       ,'tb_pos_sales_calendar_flat_qbi' AS table_name
	       ,MAX(created_dt)                  AS created_dt
	       ,MAX(report_date)                 AS report_date
	FROM edw_cl7733.tb_pos_sales_calendar_flat_qbi
	WHERE dt >= '20250201' 
	UNION ALL
	SELECT  'P3-POS日报-农历'                 AS dashboard_name
	       ,'tb_pos_sales_lunar_flat_qbi' AS table_name
	       ,MAX(created_dt)               AS created_dt
	       ,MAX(report_date)              AS report_date
	FROM edw_cl7733.tb_pos_sales_lunar_flat_qbi
	WHERE dt >= '20250201' 
	UNION ALL
	SELECT  'P3-销售总览-01OverviewKPI'                AS dashboard_name
	       ,'vw_sellin_coverpage_monthly_flat_qbi' AS table_name
	       ,MAX(created_dt)                        AS created_dt
	       ,MAX(fiscal_year_month)                 AS report_date
	FROM edw_cl7733.vw_sellin_coverpage_monthly_flat_qbi
	UNION ALL
	SELECT  'P3-销售总览-02渠道分析'                                  AS dashboard_name
	       ,'vw_sales_overview_channel_anal_monthly_flat_qbi' AS table_name
	       ,MAX(created_dt)                                   AS created_dt
	       ,MAX(fiscal_year_month)                            AS report_date
	FROM edw_cl7733.vw_sales_overview_channel_anal_monthly_flat_qbi
	UNION ALL
	SELECT  'P3-销售总览-03TopCustomer'            AS dashboard_name
	       ,'vw_top_dt_sales_monthly_flat_qbi' AS table_name
	       ,MAX(created_dt)                    AS created_dt
	       ,MAX(fiscal_year_month)             AS report_date
	FROM edw_cl7733.vw_top_dt_sales_monthly_flat_qbi
	UNION ALL
	SELECT  'P3-销售总览-进销存分析'                                   AS dashboard_name
	       ,'tb_sales_overview_monthly_flat_qbi'              AS table_name
	       ,MAX(created_dt)                                   AS created_dt
	       ,MAX(fiscal_year_show || ' ' || fiscal_month_show) AS report_date
	FROM edw_cl7733.tb_sales_overview_monthly_flat_qbi
	WHERE mt > '202501' 
	UNION ALL
	SELECT  ' P01-sellin'           AS dashboard_name
	       ,'tb_billing_daily_fact' AS table_name
	       ,MAX(created_dt)         AS created_dt
	       ,MAX(calendar_date)      AS report_date
	FROM edw_cl7733.tb_billing_daily_fact
	WHERE calendar_date > '20250101' 
	UNION ALL
	SELECT  ' P01-sellin-库存'                   AS dashboard_name
	       ,'tb_dms_stock_daily_overview_fact' AS table_name
	       ,MAX(created_dt)                    AS created_dt
	       ,MAX(dt)                            AS report_date
	FROM edw_cl7733.tb_dms_stock_daily_overview_fact
	WHERE dt > '20250101' 
	UNION ALL
	SELECT  ' P01-sellout-monthly'                   AS dashboard_name
	       ,'tb_dms_sales_monthly_fact'              AS table_name
	       ,MAX(created_dt)                          AS created_dt
	       ,MAX(fiscal_year || ' P' || fiscal_month) AS report_date
	FROM edw_cl7733.tb_dms_sales_monthly_fact
	UNION ALL
	SELECT  ' P01-sellout-daily'                     AS dashboard_name
	       ,'tb_dms_sales_daily_fact'                AS table_name
	       ,MAX(created_dt)                          AS created_dt
	       ,MAX(fiscal_year || ' P' || fiscal_month) AS report_date
	FROM edw_cl7733.tb_dms_sales_daily_fact
	WHERE dt > '20250101' 
	UNION ALL
	SELECT  ' P01-pos-daily'          AS dashboard_name
	       ,'tb_pos_sales_daily_fact' AS table_name
	       ,MAX(created_dt)           AS created_dt
	       ,MAX(report_date)          AS report_date
	FROM edw_cl7733.tb_pos_sales_daily_fact
	WHERE report_date > '20250101' 
	UNION ALL
	SELECT  'P01-pos-库存'                  AS dashboard_name
	       ,'tb_pos_inventory_daily_fact' AS table_name
	       ,MAX(created_dt)               AS created_dt
	       ,MAX(report_date)              AS report_date
	FROM edw_cl7733.tb_pos_inventory_daily_fact
	WHERE dt > '20240101' 
	UNION ALL
	SELECT  '权限表'                               AS dashboard_name
	       ,'tb_user_access_management_cfg_qbi' AS table_name
	       ,MAX(created_dt)                     AS created_dt
	       ,null                                AS report_date
	FROM edw_cl7733.tb_user_access_management_cfg_qbi
)
SELECT  *
       ,CURRENT_DATE()                                                                   AS today
       ,cast(to_date(substring(created_dt,1,10),'yyyy-mm-dd') AS date) >= CURRENT_DATE() AS flag
FROM cte_res