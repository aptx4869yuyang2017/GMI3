WITH max_month AS
(
	SELECT  fiscal_month_consecutive
	FROM vw_dim_gm_date_master
	WHERE date_key = TO_CHAR(date_sub(GETDATE(), 1), 'yyyymmdd')
	GROUP BY  fiscal_month_consecutive
), dim_date AS
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
	       ,LPAD(fiscal_day_of_month,2,'0')                                     AS fiscal_day
	       ,fiscal_week_of_month
	       ,fiscal_day_of_year
	       ,fiscal_week_of_year
	       ,CONCAT( 'F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2) ) AS fiscal_year_month
	       ,int(fiscal_year * 12 + fiscal_month)                                AS fiscal_month_conse
	       ,int( fiscal_year * 4 + int(SUBSTRING(fiscal_quarter,-1)) )          AS fiscal_quarter_conse
	       ,CASE WHEN fiscal_month_consecutive < (
	SELECT  fiscal_month_consecutive
	FROM max_month ) THEN date_key_end_for_target_mtd else TO_CHAR(date_sub(GETDATE(), 1), 'yyyymmdd') end AS act_month_end
	FROM vw_dim_gm_date_master
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
) , fact AS
(
	SELECT  calendar_date
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
	       ,SUM(billing_qty_ly)                                                                                                                AS cases_ly
	       ,SUM(list_price_revenue_excl_r100_ly)                                                                                               AS gsv_comp_ly
	       ,SUM(le_case_org)                                                                                                                   AS le_case_org
	       ,SUM(le_gsv_org)*1e3                                                                                                                AS le_gsv_org
	       ,SUM(le_case_org)                                                                                                                   AS st_case_org
	       ,SUM(le_gsv_org)*1e3                                                                                                                AS st_gsv_org
	       ,SUM(sp_case_org)                                                                                                                   AS sp_case_org
	       ,SUM(sp_gsv_org)*1e3                                                                                                                AS sp_gsv_org
	       ,SUM(le_case_customer)                                                                                                              AS le_case_customer
	       ,SUM(le_gsv_customer)*1e3                                                                                                           AS le_gsv_customer
	       ,SUM(sp_case_customer)                                                                                                              AS sp_case_customer
	       ,SUM(sp_gsv_customer)*1e3                                                                                                           AS sp_gsv_customer
	       ,SUM(le_case_customer)                                                                                                              AS st_case_customer
	       ,SUM(le_gsv_customer)*1e3                                                                                                           AS st_gsv_customer
	       ,SUM(le_case_product)                                                                                                               AS le_case_product
	       ,SUM(le_gsv_product)*1e3                                                                                                            AS le_gsv_product
	       ,0                                                                                                                                  AS sp_case_product
	       ,0                                                                                                                                  AS sp_gsv_product
	       ,SUM(stock_count_unit_qty)                                                                                                          AS stock_case
	       ,SUM(stock_gsv_mdm)                                                                                                                 AS stock_gsv
	       ,SUM(stock_count_unit_qty_ly)                                                                                                       AS stock_case_ly
	       ,SUM(stock_gsv_mdm_ly)                                                                                                              AS stock_gsv_ly
	       ,SUM(sellout_past_28days_count_unit_qty)/28                                                                                         AS sellout_past_case
	       ,SUM(sellout_past_28days_gsv_mdm)/28                                                                                                AS sellout_past_gsv
	       ,SUM(sellout_next_28days_count_unit_qty)/28                                                                                         AS sellout_next_case
	       ,SUM(sellout_next_28days_gsv_mdm)/28                                                                                                AS sellout_next_gsv
	       ,SUM(sellout_past_28days_count_unit_qty_ly)/28                                                                                      AS sellout_past_case_ly
	       ,SUM(sellout_past_28days_gsv_mdm_ly)/28                                                                                             AS sellout_past_gsv_ly
	       ,SUM(sellout_next_28days_count_unit_qty_ly)/28                                                                                      AS sellout_next_case_ly
	       ,SUM(sellout_next_28days_gsv_mdm_ly)/28                                                                                             AS sellout_next_gsv_ly
	       ,SUM(count_unit_qty)                                                                                                                AS sellout_case
	       ,SUM(gsv_mdm)                                                                                                                       AS sellout_gsv
	       ,SUM(count_unit_qty_ly)                                                                                                             AS sellout_case_ly
	       ,SUM(gsv_mdm_ly)                                                                                                                    AS sellout_gsv_ly
	FROM tb_billing_data
	GROUP BY  calendar_date
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
(
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
	SELECT  ''    AS level_0
	       ,'TTL' AS level_1
	       ,'TTL' AS level_2
	       ,'X'   AS data_type
	       ,t.*
	FROM fact AS t
	WHERE business_area_name IN ('餐饮', '零售', '电商') 
)
SELECT  t1.*
       ,t2.*
       ,t3.mtd_time_pasting
       ,t3.qtd_time_pasting
       ,t3.ytd_time_pasting
       ,CASE WHEN t1.calendar_date = t2.act_month_end THEN 'Y'  ELSE 'N' END AS act_month_end_filter
FROM fact_multi AS t1
LEFT JOIN dim_date AS t2
ON t1.calendar_date = t2.date_key
LEFT JOIN time_past AS t3
ON t2.fiscal_year = t3.fiscal_year AND t2.fiscal_month = t3.fiscal_month
WHERE t2.fiscal_year >= 2025
AND product_brand_name IN ('哈根达斯'，'湾仔码头')