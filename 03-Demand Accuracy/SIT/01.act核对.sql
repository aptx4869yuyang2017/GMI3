WITH all_t AS
(
	SELECT  product_brand_name
	       ,business_area_name
	       ,fiscal_month
	       ,SUM(sellin_case) AS sellin_case
	FROM tb_sales_overview_monthly_flat_qbi -- Non-Shop-进销存分析数据集
	WHERE mt <> ''
	AND fiscal_year = 2025
	AND fiscal_month IN (6, 10)
	AND product_brand_name IN ( '湾仔码头', '哈根达斯' )
	GROUP BY  product_brand_name
	         ,business_area_name
	         ,fiscal_month
) , cte_demand AS
(
	SELECT  fiscal_month
	       ,product_brand_name
	       ,business_area_name
	       ,SUM(cases_act) AS sellin_case
	FROM vw_sellin_demand_accuracy_flat_qbi --demand accuracy
    WHERE mt <> ''
	WHERE 1 = 1
	AND fiscal_year = 2025
	AND fiscal_month IN (6, 10)
	AND product_brand_name IN ( '湾仔码头', '哈根达斯' )
	GROUP BY  fiscal_month
	         ,product_brand_name
	         ,business_area_name
)
SELECT  t1.fiscal_month
       ,t1.product_brand_name
       ,t1.business_area_name
       ,t1.sellin_case
       ,t2.sellin_case                  AS sellin_case2
       ,t1.sellin_case - t2.sellin_case AS diff12
FROM cte_demand AS t1
LEFT JOIN all_t AS t2
ON t1.product_brand_name = t2.product_brand_name AND t1.business_area_name = t2.business_area_name AND t1.fiscal_month = t2.fiscal_month
ORDER BY t1.fiscal_month, t1.product_brand_name, t1.business_area_name