WITH coverpage AS
(
	SELECT  product_brand_name
	       ,business_area_name
	       ,fiscal_month
	       ,SUM(cases) AS sellin_case
	FROM vw_sellin_coverpage_monthly_flat_qbi
	WHERE date_range_type = 'MTD'
	AND fiscal_year = 2025
	AND fiscal_month IN (9, 10)
	AND product_brand_name IN ( '湾仔码头', '哈根达斯' )
	GROUP BY  product_brand_name
	         ,business_area_name
	         ,fiscal_month
), all AS
(
	SELECT  product_brand_name
	       ,business_area_name
	       ,fiscal_month
	       ,SUM(sellin_case) AS sellin_case
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = 2025
	AND fiscal_month IN (9, 10)
	AND product_brand_name IN ( '湾仔码头', '哈根达斯' )
	GROUP BY  product_brand_name
	         ,business_area_name
	         ,fiscal_month
)
SELECT  t1.fiscal_month
       ,t1.product_brand_name
       ,t1.business_area_name
       ,t1.sellin_case
       ,t2.sellin_case AS sellin_case2
       ,t1.sellin_case - t2.sellin_case as diff
FROM coverpage AS t1
LEFT JOIN all AS t2
ON t1.product_brand_name = t2.product_brand_name AND t1.business_area_name = t2.business_area_name AND t1.fiscal_month = t2.fiscal_month
ORDER BY t1.fiscal_month, t1.product_brand_name, t1.business_area_name