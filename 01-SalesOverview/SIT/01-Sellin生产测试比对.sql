-- 渠道粒度 对比 测试环境数据 与 Mercury生产数据
WITH t_new AS
(
	SELECT  fiscal_month
	       ,product_brand_name
	       ,business_area_name
	       ,SUM(billing_qty)                  AS cases
	       ,SUM(list_price_revenue_excl_r100) AS gsv
	FROM edw_cl7733_dev.tb_billing_data
	WHERE fiscal_year = 2025
	AND fiscal_quarter = 'Q2'
	AND product_brand_name IN ('哈根达斯', '湾仔码头')
	AND business_area_name IN ('电商', '餐饮', '零售')
	GROUP BY  fiscal_month
	         ,product_brand_name
	         ,business_area_name
) , t_old AS
(
	SELECT  fiscal_month
	       ,product_brand_name
	       ,business_area_name
	       ,SUM(billing_qty)                  AS cases
	       ,SUM(list_price_revenue_excl_r100) AS gsv
	FROM edw_cl7733.tb_billing_daily_fact
	WHERE fiscal_year = 2025
	AND fiscal_quarter = 'Q2'
	AND product_brand_name IN ('哈根达斯', '湾仔码头')
	AND business_area_name IN ('电商', '餐饮', '零售')
	GROUP BY  fiscal_month
	         ,product_brand_name
	         ,business_area_name
	ORDER BY  fiscal_month
	         ,product_brand_name
	         ,business_area_name
) , res as(
SELECT  t1.fiscal_month
       ,t1.product_brand_name
       ,t1.business_area_name
       ,CASE WHEN t1.cases = t2.cases THEN 'Y' END AS case_same
       ,t1.cases                                   AS old_case
       ,t2.cases                                   AS new_case
       ,CASE WHEN t1.gsv = t2.gsv THEN 'Y' END     AS gsv_same
       ,t1.gsv                                     AS old_gsv
       ,t2.gsv                                     AS new_gsv
FROM t_old AS t1
LEFT JOIN t_new AS t2
ON t1.fiscal_month = t2.fiscal_month AND t1.product_brand_name = t2.product_brand_name AND t1.business_area_name = t2.business_area_name)
SELECT  *
FROM res
ORDER BY fiscal_month, product_brand_name, business_area_name