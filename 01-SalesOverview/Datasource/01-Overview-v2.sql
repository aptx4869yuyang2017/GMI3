SELECT  t1.date_range_type as xtd_type
       ,t1.fiscal_year
       ,t1.fiscal_month
       ,t1.business_area_name
       ,t1.product_brand_name
       ,t1.cases
       ,t1.gsv
       ,t1.case_ly
       ,t1.gsv_ly
       ,t1.le_case
       ,t1.le_gsv * 1e3 as le_gsv
       ,t1.sp_case
       ,t1.sp_gsv * 1e3 as sp_gsv
       ,t1.st_case
       ,t1.st_gsv * 1e3 as st_gsv
       ,t1.fiscal_quarter
       ,t1.fiscal_yp
       ,t1.fiscal_year_month
       ,t1.fiscal_month_conse
       ,t1.fiscal_quarter_conse
       ,t1.time_pasting
FROM vw_sellin_coverpage_monthly_flat_qbi t1
WHERE t1.fiscal_year >= 2025
AND t1.product_brand_name IN ('哈根达斯', '湾仔码头')