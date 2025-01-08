-- 临时表说明
-- dim_date: 构建临时日期表增加备用相关字段
-- dim_date_monthly: 月粒度维度表，方便月粒度数据使用
-- time_past: 计算月粒度的时间进度
-- time_past_row: 对 time_past MTD/QTD/YTD 列转行 方便后续 列转行数据使用
-- fact: 来自 tb_billing_data 的数据进行 月粒度 聚合
-- fact_multi: 根据页面要求，构造 level_0 / level_1 / level_2 层级，会产生数据重复
-- fact_org: 在展示粒度上进行数据聚合 财年月 + 品牌 + Level_012
-- ytd/qtd_target/qtd_act: 构造 对应时间范围的数据
-- fact_union: union mtd/qtd/ytd 相关数据，并计算 产品总量

WITH dim_date AS
(
	SELECT  date_key
	       ,date_key_ly
	       ,week_day
	       ,lunar_date
	       ,fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,fiscal_yp
	       ,fiscal_day_of_month
	       ,LPAD(fiscal_day_of_month,2,'0')                                  AS fiscal_day
	       ,fiscal_week_of_month
	       ,fiscal_day_of_year
	       ,fiscal_week_of_year
	       ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2)) AS fiscal_year_month
	       ,int(fiscal_year * 12 + fiscal_month)                             AS fiscal_month_conse
	       ,int(fiscal_year * 4 + int(SUBSTRING(fiscal_quarter,-1)))         AS fiscal_quarter_conse
	       ,date_key_end_for_target_mtd                                      AS mtd_end
	       ,date_key_end_for_target_qtd                                      AS qtd_end
	       ,date_key_end_for_target_ytd                                      AS ytd_end
	FROM vw_dim_gm_date_master
) , dim_date_monthly AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,fiscal_yp
	       ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2)) AS fiscal_year_month
	       ,int(fiscal_year * 12 + fiscal_month)                             AS fiscal_month_conse
	       ,int(fiscal_year * 4 + int(SUBSTRING(fiscal_quarter,-1)))         AS fiscal_quarter_conse
	       ,MAX(date_key_end_for_target_mtd)                                 AS mtd_end
	       ,MAX(date_key_end_for_target_qtd)                                 AS qtd_end
	       ,MAX(date_key_end_for_target_ytd)                                 AS ytd_end
	FROM vw_dim_gm_date_master
	GROUP BY  fiscal_year
	         ,fiscal_month
	         ,fiscal_quarter
	         ,fiscal_yp
	         ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2))
	         ,int(fiscal_year * 12 + fiscal_month)
	         ,int(fiscal_year * 4 + int(SUBSTRING(fiscal_quarter,-1)))
) , time_past AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,MAX(round(time_pasting_rate_of_month,4))   AS mtd_time_pasting
	       ,MAX(round(time_pasting_rate_of_quarter,4)) AS qtd_time_pasting
	       ,MAX(round(fiscal_day_of_year / (DATEDIFF(TO_DATE(date_key_end_for_target_mtd,'yyyymmdd'),TO_DATE(date_key_start_ytd,'yyyymmdd'),'day') + 1),4)) AS ytd_time_pasting
	FROM vw_dim_gm_date_master
	WHERE date_key < TO_CHAR(GETDATE(), 'yyyymmdd')
	GROUP BY  fiscal_year
	         ,fiscal_month
) , time_past_row AS
(
	SELECT  'MTD'            AS union_type
	       ,fiscal_year
	       ,fiscal_month
	       ,mtd_time_pasting AS time_pasting
	FROM time_past
	UNION ALL
	SELECT  'QTD'            AS union_type
	       ,fiscal_year
	       ,fiscal_month
	       ,qtd_time_pasting AS time_pasting
	FROM time_past
	UNION ALL
	SELECT  'YTD'            AS union_type
	       ,fiscal_year
	       ,fiscal_month
	       ,ytd_time_pasting AS time_pasting
	FROM time_past
) , fact AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,product_brand_name
	       ,business_area_name
	       ,sales_district_name
	       ,customer_group_3_name
	       ,customer_group_2_name
	       ,customer_group_5_name
	       ,customer_group_name
	       ,product_category_name
	       ,product_midcategory_name
	       ,product_subcategory_name
	       ,product_strategy
	       ,product_cate5_name
	       ,is_new_product_flag
	       ,CASE WHEN business_area_name = '零售' AND customer_group_3_name IN ('NKA','RKA','LKA') THEN customer_group_name  ELSE payer_name END AS customer_name
	       ,CAST(CAST(stat_weight AS BIGINT) AS STRING) || stat_weight_unit_name                                                               AS stat_weight
	       ,SUM(billing_qty)                                                                                                                   AS cases
	       ,SUM(list_price_revenue_excl_r100)                                                                                                  AS gsv_comp
	       ,SUM(billing_qty_ly)                                                                                                                AS case_ly
	       ,SUM(list_price_revenue_excl_r100_ly)                                                                                               AS gsv_comp_ly
	       ,SUM(le_case_org)                                                                                                                   AS le_case_org
	       ,SUM(le_gsv_org)*1e3                                                                                                                AS le_gsv_org
	       ,SUM(sp_case_org)                                                                                                                   AS sp_case_org
	       ,SUM(sp_gsv_org)*1e3                                                                                                                AS sp_gsv_org
	       ,SUM(sp_case_org)                                                                                                                   AS st_case_org
	       ,SUM(sp_gsv_org)*1e3                                                                                                                AS st_gsv_org
	       ,SUM(le_case_customer)                                                                                                              AS le_case_customer
	       ,SUM(le_gsv_customer)*1e3                                                                                                           AS le_gsv_customer
	       ,SUM(sp_case_customer)                                                                                                              AS sp_case_customer
	       ,SUM(sp_gsv_customer)*1e3                                                                                                           AS sp_gsv_customer
	       ,SUM(le_case_product)                                                                                                               AS le_case_product
	       ,SUM(le_gsv_product)*1e3                                                                                                            AS le_gsv_product
	       ,0                                                                                                                                  AS sp_case_product
	       ,0                                                                                                                                  AS sp_gsv_product
	       ,SUM(stock_count_unit_qty)                                                                                                          AS stock_case
	       ,SUM(stock_gsv_mdm)                                                                                                                 AS stock_gsv
	       ,SUM(sellout_past_28days_count_unit_qty)/28                                                                                         AS sellout_past_case
	       ,SUM(sellout_past_28days_gsv_mdm)/28                                                                                                AS sellout_past_gsv
	       ,SUM(sellout_next_28days_count_unit_qty)/28                                                                                         AS sellout_next_case
	       ,SUM(sellout_next_28days_gsv_mdm)/28                                                                                                AS sellout_next_gsv
	       ,SUM(count_unit_qty)                                                                                                                AS sellout_case
	       ,SUM(gsv_mdm)                                                                                                                       AS sellout_gsv
	       ,SUM(count_unit_qty_ly)                                                                                                             AS sellout_case_ly
	       ,SUM(gsv_mdm_ly)                                                                                                                    AS sellout_gsv_ly
	FROM tb_billing_data
	GROUP BY  fiscal_year
	         ,fiscal_quarter
	         ,fiscal_month
	         ,product_brand_name
	         ,business_area_name
	         ,sales_district_name
	         ,customer_group_3_name
	         ,customer_group_2_name
	         ,customer_group_5_name
	         ,customer_group_name
	         ,product_category_name
	         ,product_midcategory_name
	         ,product_subcategory_name
	         ,product_strategy
	         ,product_cate5_name
	         ,is_new_product_flag
	         ,CAST(CAST(stat_weight AS BIGINT) AS STRING) || stat_weight_unit_name
	         ,CASE WHEN business_area_name = '零售' AND customer_group_3_name IN ('NKA','RKA','LKA') THEN customer_group_name  ELSE payer_name END
), fact_multi AS
( -- DT / RK A
	SELECT  '零售-细分'                                                                                AS level_0
	       ,CASE WHEN customer_group_3_name = '经销商' THEN 'DT'
	             WHEN customer_group_3_name = 'RKA+LKA' THEN 'RKA'  ELSE customer_group_3_name END AS level_1
	       ,REPLACE(sales_district_name,'零售--','')                                                 AS level_2
	       ,'X'                                                                                    AS data_type
	       ,t.*
	FROM fact AS t
	WHERE business_area_name = '零售'
	AND customer_group_3_name IN ( '经销商', 'RKA+LKA' , 'NKA') 
	UNION ALL
	 -- Retail
	SELECT  'TTL'                                  AS level_0
	       ,'Retail'                               AS level_1
	       ,REPLACE(sales_district_name,'零售--','') AS level_2
	       ,'Y'                                    AS data_type
	       ,t.*
	FROM fact AS t
	WHERE business_area_name = '零售' 
	UNION ALL
	SELECT  'TTL'                                                                AS level_0
	       ,'EC+HEMA'                                                            AS level_1
	       ,CASE WHEN sales_district_name = '盒马Group' THEN 'HEMA'  ELSE 'EC' END AS level_2
	       ,'Y'                                                                  AS data_type
	       ,t.*
	FROM fact AS t
	WHERE business_area_name = '电商' 
	UNION ALL
	SELECT  'TTL' AS level_0
	       ,'餐饮'  AS level_1
	       ,'餐饮'  AS level_2
	       ,'Y'   AS data_type
	       ,t.*
	FROM fact AS t
	WHERE business_area_name = '餐饮' 
	UNION ALL
	SELECT  'TTL'  AS level_0
	       ,'Shop' AS level_1
	       ,'Shop' AS level_2
	       ,'X'    AS data_type
	       ,t.*
	FROM fact AS t
	WHERE business_area_name = 'Shop' 
	UNION ALL
	SELECT  ''    AS level_0
	       ,'TTL' AS level_1
	       ,'TTL' AS level_2
	       ,'X'   AS data_type
	       ,t.*
	FROM fact AS t
	WHERE business_area_name IN ('餐饮', '零售', '电商', 'Shop') 
), fact_org AS
(
	SELECT  fiscal_year
	       ,fiscal_quarter
	       ,fiscal_month
	       ,level_0
	       ,level_1
	       ,level_2
	       ,data_type
	       ,product_brand_name
	       ,SUM(cases)             AS cases
	       ,SUM(gsv_comp)          AS gsv_comp
	       ,SUM(case_ly)           AS case_ly
	       ,SUM(gsv_comp_ly)       AS gsv_comp_ly
	       ,SUM(le_case_org)       AS le_case_org
	       ,SUM(le_gsv_org)        AS le_gsv_org
	       ,SUM(sp_case_org)       AS sp_case_org
	       ,SUM(sp_gsv_org)        AS sp_gsv_org
	       ,SUM(st_case_org)       AS st_case_org
	       ,SUM(st_gsv_org)        AS st_gsv_org
	       ,SUM(le_case_customer)  AS le_case_customer
	       ,SUM(le_gsv_customer)   AS le_gsv_customer
	       ,SUM(sp_case_customer)  AS sp_case_customer
	       ,SUM(sp_gsv_customer)   AS sp_gsv_customer
	       ,SUM(le_case_product)   AS le_case_product
	       ,SUM(le_gsv_product)    AS le_gsv_product
	       ,SUM(sp_case_product)   AS sp_case_product
	       ,SUM(sp_gsv_product)    AS sp_gsv_product
	       ,SUM(stock_case)        AS stock_case
	       ,SUM(stock_gsv)         AS stock_gsv
	       ,SUM(sellout_past_case) AS sellout_past_case
	       ,SUM(sellout_past_gsv)  AS sellout_past_gsv
	       ,SUM(sellout_next_case) AS sellout_next_case
	       ,SUM(sellout_next_gsv)  AS sellout_next_gsv
	       ,SUM(sellout_case)      AS sellout_case
	       ,SUM(sellout_gsv)       AS sellout_gsv
	       ,SUM(sellout_case_ly)   AS sellout_case_ly
	       ,SUM(sellout_gsv_ly)    AS sellout_gsv_ly
	FROM fact_multi
	GROUP BY  fiscal_year
	         ,fiscal_quarter
	         ,fiscal_month
	         ,level_0
	         ,level_1
	         ,level_2
	         ,data_type
	         ,product_brand_name
), ytd AS
(
	SELECT  t2.fiscal_year
	       ,t2.fiscal_month
	       ,t1.level_0
	       ,t1.level_1
	       ,t1.level_2
	       ,t1.data_type
	       ,t1.product_brand_name
	       ,SUM(cases)                                                                  AS cases
	       ,SUM(gsv_comp)                                                               AS gsv_comp
	       ,SUM(case_ly)                                                                AS case_ly
	       ,SUM(gsv_comp_ly)                                                            AS gsv_comp_ly
	       ,SUM(le_case_org)                                                            AS le_case_org
	       ,SUM(le_gsv_org)                                                             AS le_gsv_org
	       ,SUM(sp_case_org)                                                            AS sp_case_org
	       ,SUM(sp_gsv_org)                                                             AS sp_gsv_org
	       ,SUM(st_case_org)                                                            AS st_case_org
	       ,SUM(st_gsv_org)                                                             AS st_gsv_org
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN stock_case end)        AS stock_case
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN stock_gsv end )        AS stock_gsv
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN sellout_past_case end) AS sellout_past_case
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN sellout_past_gsv end)  AS sellout_past_gsv
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN sellout_next_case end) AS sellout_next_case
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN sellout_next_gsv end)  AS sellout_next_gsv
	FROM fact_org t1
	LEFT JOIN dim_date_monthly t2
	ON t1.fiscal_year = t2.fiscal_year
	WHERE t1.fiscal_month <= t2.fiscal_month
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_month
	         ,t1.level_0
	         ,t1.level_1
	         ,t1.level_2
	         ,t1.data_type
	         ,t1.product_brand_name
) , qtd_act AS
(
	SELECT  t2.fiscal_year
	       ,t2.fiscal_month
	       ,t1.level_0
	       ,t1.level_1
	       ,t1.level_2
	       ,t1.data_type
	       ,t1.product_brand_name
	       ,SUM(cases)                                                                  AS cases
	       ,SUM(gsv_comp)                                                               AS gsv_comp
	       ,SUM(case_ly)                                                                AS case_ly
	       ,SUM(gsv_comp_ly)                                                            AS gsv_comp_ly
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN stock_case end)        AS stock_case
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN stock_gsv end )        AS stock_gsv
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN sellout_past_case end) AS sellout_past_case
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN sellout_past_gsv end)  AS sellout_past_gsv
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN sellout_next_case end) AS sellout_next_case
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN sellout_next_gsv end)  AS sellout_next_gsv
	FROM fact_org t1
	LEFT JOIN dim_date_monthly t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_quarter = t2.fiscal_quarter
	WHERE t1.fiscal_month <= t2.fiscal_month
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_month
	         ,t1.level_0
	         ,t1.level_1
	         ,t1.level_2
	         ,t1.data_type
	         ,t1.product_brand_name
), qtd_target AS
(
	SELECT  t2.fiscal_year
	       ,t2.fiscal_month
	       ,t1.level_0
	       ,t1.level_1
	       ,t1.level_2
	       ,t1.data_type
	       ,t1.product_brand_name
	       ,SUM(le_case_org) AS le_case_org
	       ,SUM(le_gsv_org)  AS le_gsv_org
	       ,SUM(sp_case_org) AS sp_case_org
	       ,SUM(sp_gsv_org)  AS sp_gsv_org
	       ,SUM(st_case_org) AS st_case_org
	       ,SUM(st_gsv_org)  AS st_gsv_org
	FROM fact_org t1
	LEFT JOIN dim_date_monthly t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_quarter = t2.fiscal_quarter -- WHERE t1.fiscal_month <= t2.fiscal_month
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_month
	         ,t1.level_0
	         ,t1.level_1
	         ,t1.level_2
	         ,t1.data_type
	         ,t1.product_brand_name
), fact_union AS
(
	SELECT  'MTD'        AS union_type
	       ,t1.fiscal_year
	       ,t1.fiscal_month
	       ,t1.level_0
	       ,t1.level_1
	       ,t1.level_2
	       ,t1.data_type
	       ,t1.product_brand_name
	       ,t1.cases
	       ,t1.gsv_comp
	       ,t1.case_ly
	       ,t1.gsv_comp_ly
	       ,t1.stock_case
	       ,t1.stock_gsv
	       ,t1.sellout_past_case
	       ,t1.sellout_past_gsv
	       ,t1.sellout_next_case
	       ,t1.sellout_next_gsv
	       ,t1.le_case_org
	       ,t1.le_gsv_org
	       ,t1.sp_case_org
	       ,t1.sp_gsv_org
	       ,t1.st_case_org
	       ,t1.st_gsv_org
	       ,ttl.cases    AS case_total
	       ,ttl.gsv_comp AS gsv_comp_total
	FROM fact_org AS t1
	LEFT JOIN
	(
		SELECT  *
		FROM fact_org
		WHERE level_0 = '' 
	) AS ttl
	ON t1.fiscal_year = ttl.fiscal_year AND t1.fiscal_month = ttl.fiscal_month AND t1.product_brand_name = ttl.product_brand_name
	UNION ALL
	SELECT  'QTD'            AS union_type
	       ,t1.fiscal_year
	       ,t1.fiscal_month
	       ,t1.level_0
	       ,t1.level_1
	       ,t1.level_2
	       ,t1.data_type
	       ,t1.product_brand_name
	       ,t1.cases
	       ,t1.gsv_comp
	       ,t1.case_ly
	       ,t1.gsv_comp_ly
	       ,t1.stock_case
	       ,t1.stock_gsv
	       ,t1.sellout_past_case
	       ,t1.sellout_past_gsv
	       ,t1.sellout_next_case
	       ,t1.sellout_next_gsv
	       ,t2.le_case_org
	       ,t2.le_gsv_org
	       ,t2.sp_case_org
	       ,t2.sp_gsv_org
	       ,t2.st_case_org
	       ,t2.st_gsv_org
	       ,qtd_ttl.cases    AS case_total
	       ,qtd_ttl.gsv_comp AS gsv_comp_total
	FROM qtd_act AS t1
	LEFT JOIN qtd_target AS t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month AND t1.level_0 = t2.level_0 AND t1.level_1 = t2.level_1 AND t1.level_2 = t2.level_2 AND t1.data_type = t2.data_type AND t1.product_brand_name = t2.product_brand_name
	LEFT JOIN
	(
		SELECT  *
		FROM qtd_act
		WHERE level_0 = '' 
	) qtd_ttl
	ON t1.fiscal_year = qtd_ttl.fiscal_year AND t1.fiscal_month = qtd_ttl.fiscal_month AND t1.product_brand_name = qtd_ttl.product_brand_name
	UNION ALL
	SELECT  'YTD'        AS union_type
	       ,t1.fiscal_year
	       ,t1.fiscal_month
	       ,t1.level_0
	       ,t1.level_1
	       ,t1.level_2
	       ,t1.data_type
	       ,t1.product_brand_name
	       ,t1.cases
	       ,t1.gsv_comp
	       ,t1.case_ly
	       ,t1.gsv_comp_ly
	       ,t1.stock_case
	       ,t1.stock_gsv
	       ,t1.sellout_past_case
	       ,t1.sellout_past_gsv
	       ,t1.sellout_next_case
	       ,t1.sellout_next_gsv
	       ,t1.le_case_org
	       ,t1.le_gsv_org
	       ,t1.sp_case_org
	       ,t1.sp_gsv_org
	       ,t1.st_case_org
	       ,t1.st_gsv_org
	       ,ttl.cases    AS case_total
	       ,ttl.gsv_comp AS gsv_comp_total
	FROM ytd AS t1
	LEFT JOIN
	(
		SELECT  *
		FROM ytd
		WHERE level_0 = '' 
	) AS ttl
	ON t1.fiscal_year = ttl.fiscal_year AND t1.fiscal_month = ttl.fiscal_month AND t1.product_brand_name = ttl.product_brand_name
)
SELECT  t1.*
       ,t2.fiscal_yp
       ,t2.fiscal_year_month
       ,t2.fiscal_month_conse
       ,t2.fiscal_quarter_conse
       ,t2.mtd_end
       ,t2.qtd_end
       ,t2.ytd_end
       ,t3.time_pasting
FROM fact_union t1
LEFT JOIN dim_date_monthly AS t2
ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month
LEFT JOIN time_past_row AS t3
ON t2.fiscal_year = t3.fiscal_year AND t2.fiscal_month = t3.fiscal_month AND t1.union_type = t3.union_type
WHERE t2.fiscal_year >= 2025
AND t1.product_brand_name IN ('哈根达斯', '湾仔码头')
AND level_2 NOT IN ('达上', '未匹配')