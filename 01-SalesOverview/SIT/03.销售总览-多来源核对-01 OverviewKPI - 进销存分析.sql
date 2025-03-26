WITH OverviewKPI AS
(
	SELECT  product_brand_name
	       ,business_area_name
	       ,fiscal_month
	       ,SUM(cases) AS sellin_case
	FROM vw_sellin_coverpage_monthly_flat_qbi --销售总览-01OverviewKPI
	WHERE date_range_type = 'MTD'
	AND fiscal_year = 2025
	AND fiscal_month IN (6, 10)
	AND product_brand_name IN ( '湾仔码头', '哈根达斯' )
	GROUP BY  product_brand_name
	         ,business_area_name
	         ,fiscal_month
), all_t AS
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
), channel_t AS
(
	SELECT  product_brand_name
	       ,case when level_1 = 'EC+HEMA' then '电商' when level_1='Retail' then '零售' else level_1 end as business_area_name
	       ,fiscal_month
	       ,nvl(SUM(cases),0) AS sellin_case
	FROM vw_sales_overview_channel_anal_monthly_flat_qbi -- 渠道分析
	WHERE date_range_type = 'MTD'
	AND fiscal_year = 2025
	AND fiscal_month IN (6, 10)
	AND product_brand_name IN ( '湾仔码头', '哈根达斯' )
    and level_1 in ('EC+HEMA', '餐饮', 'BD', '未匹配', 'Retail')
	GROUP BY  product_brand_name
	         ,case when level_1 = 'EC+HEMA' then '电商' when level_1='Retail' then '零售' else level_1 end
	         ,fiscal_month
)
SELECT  t1.fiscal_month
       ,t1.product_brand_name
       ,t1.business_area_name
       ,t1.sellin_case
       ,t2.sellin_case AS sellin_case2
       ,t3.sellin_case as sellin_case3
       ,t1.sellin_case - t2.sellin_case as diff12
       ,t1.sellin_case - t3.sellin_case as diff13
FROM OverviewKPI AS t1
LEFT JOIN all_t AS t2
ON t1.product_brand_name = t2.product_brand_name AND t1.business_area_name = t2.business_area_name AND t1.fiscal_month = t2.fiscal_month
left join channel_t as t3
ON t1.product_brand_name = t3.product_brand_name AND t1.business_area_name = t3.business_area_name AND t1.fiscal_month = t3.fiscal_month
ORDER BY t1.fiscal_month, t1.product_brand_name, t1.business_area_name

