SELECT  t1.xtd_type
       ,t1.fiscal_year
       ,t1.fiscal_month
       ,t1.business_area_name
       ,t1.product_brand_name
       ,t1.customer_group_3_name
       ,t1.payer_cd
       ,t1.payer_name
       ,t1.cases
       ,t1.gsv
       ,t1.case_ly
       ,t1.gsv_ly
       ,t1.stock_case
       ,t1.stock_gsv
       ,t1.sellout_past_28days_case
       ,t1.sellout_past_28days_gsv
       ,t1.sellout_next_28days_case
       ,t1.sellout_next_28days_gsv
       ,t1.le_case
       ,t1.le_gsv
       ,t1.st_case
       ,t1.st_gsv
       ,t1.fiscal_quarter
       ,t1.fiscal_yp
       ,t1.fiscal_year_month
       ,t1.fiscal_month_conse
       ,t1.fiscal_quarter_conse
       ,t1.time_pasting
FROM vw_top_customer_sales_flat_qbi t1
WHERE t1.fiscal_year >= 2024
AND t1.product_brand_name IN ('哈根达斯', '湾仔码头')