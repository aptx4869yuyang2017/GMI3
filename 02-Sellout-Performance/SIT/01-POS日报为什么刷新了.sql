-- 一期数据
SELECT  report_date
       ,SUM(pieces)
       ,MAX(created_dt)
FROM edw_cl7733.tb_pos_sales_daily_fact
WHERE report_date >= '20250224'
GROUP BY  report_date
ORDER BY  report_date
--- POS 日报数据
SELECT  report_date
       ,SUM(pieces)
       ,MAX(created_dt)
FROM edw_cl7733.tb_pos_sales_calendar_flat_qbi
WHERE dt >= '20250225'
GROUP BY  report_date