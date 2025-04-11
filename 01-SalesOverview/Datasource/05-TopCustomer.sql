SELECT  t1.date_range_type                                                                                          AS xtd_type
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
       ,CASE WHEN business_area_name = '零售' THEN stock_case_latest
             WHEN business_area_name = '餐饮' THEN stock_gsv_incl_promotion_latest END                                AS stock_doh
       ,CASE WHEN business_area_name = '零售' THEN sellout_case_latest_nm/days_of_next_fiscal_month
             WHEN business_area_name = '餐饮' THEN sellout_gsv_incl_promotion_latest_nm/days_of_next_fiscal_month END AS sellout_doh
       ,t1.le_case
       ,t1.le_gsv * 1e3                                                                                             AS le_gsv
       ,t1.st_case
       ,t1.st_gsv * 1e3                                                                                             AS st_gsv
       ,t1.fiscal_quarter
       ,t1.fiscal_yp
       ,t1.fiscal_year_month
       ,t1.fiscal_month_conse
       ,t1.fiscal_quarter_conse
       ,t1.time_pasting
FROM vw_top_dt_sales_monthly_flat_qbi t1
WHERE t1.fiscal_year >= 2024
AND t1.product_brand_name IN ('哈根达斯', '湾仔码头')