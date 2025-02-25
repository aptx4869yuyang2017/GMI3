WITH cte_overview AS
(
	SELECT  product_brand_name
	       ,business_area_name
	       ,round(SUM(sellout_case)) AS sellout_case
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = 2025
	AND fiscal_month = 7
	AND product_brand_name IN ('湾仔码头', '哈根达斯')
	GROUP BY  product_brand_name
	         ,business_area_name
) , cte_sellout AS
(
	SELECT  product_brand_name
	       ,business_area_name
	       ,round(SUM(cases)) AS sellout_case
	FROM tb_pos_dms_sales_detail_daily_flat_qbi
	WHERE dt <> ''
	AND fiscal_year = 2025
	AND fiscal_month = 7
	AND product_brand_name IN ('湾仔码头', '哈根达斯')
	GROUP BY  product_brand_name
	         ,business_area_name
)
SELECT  t1.product_brand_name
       ,t1.business_area_name
       ,t1.sellout_case
       ,t2.sellout_case AS sellout_case_2
FROM cte_overview t1
LEFT JOIN cte_sellout t2
ON t1.product_brand_name = t2.product_brand_name AND t1.business_area_name = t2.business_area_name