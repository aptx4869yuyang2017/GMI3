SELECT  t1.date_range_type AS union_type
       ,t1.fiscal_year
       ,t1.fiscal_month
       ,t1.level_0
       ,t1.level_1
       ,t1.level_2
       ,t1.data_type
       ,t1.product_brand_name
       ,SUM(t1.cases)      AS cases
       ,SUM(t1.le_case)    AS le_case_org
FROM vw_sales_overview_channel_anal_monthly_flat_qbi AS t1
WHERE t1.fiscal_year = 2025
AND t1.fiscal_month in (10, 11,12)
AND product_brand_name = '哈根达斯'
AND level_1 = 'EC+HEMA'

AND t1.level_2 NOT IN ('达上', '未匹配')
AND level_2 <> '公司调整项'
GROUP BY  t1.date_range_type
         ,t1.fiscal_year
         ,t1.fiscal_month
         ,t1.level_0
         ,t1.level_1
         ,t1.level_2
         ,t1.data_type
         ,t1.product_brand_name