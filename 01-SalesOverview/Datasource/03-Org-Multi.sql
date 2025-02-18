SELECT  t1.date_type as union_type
       ,t1.fiscal_year
       ,t1.fiscal_month
       ,t1.level_0
       ,t1.level_1
       ,t1.level_2
       ,t1.data_type
       ,t1.product_brand_name
       ,t1.cases
       ,t1.gsv as gsv_comp
       ,t1.case_ly
       ,t1.gsv_ly as gsv_comp_ly
       ,t1.stock_case
       ,t1.stock_gsv
       ,t1.sellout_past_case
       ,t1.sellout_past_gsv
       ,t1.sellout_next_case
       ,t1.sellout_next_gsv
       ,t1.le_case as le_case_org
       ,t1.le_gsv * 1e3 as le_gsv_org
       ,t1.st_case as st_case_org
       ,t1.st_gsv * 1e3 as st_gsv_org
       ,t1.case_total
       ,t1.gsv_total as gsv_comp_total
       ,t1.fiscal_yp
       ,t1.fiscal_year_month
       ,t1.fiscal_month_conse
       ,t1.fiscal_quarter_conse
       ,t1.time_pasting
FROM vw_sales_overview_channel_analysis_flat_qbi AS t1
WHERE t1.fiscal_year >= 2025
AND t1.product_brand_name IN ('哈根达斯', '湾仔码头')
AND t1.level_2 NOT IN ('达上', '未匹配')