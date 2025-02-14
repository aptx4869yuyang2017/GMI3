WITH max_month AS
(
	SELECT  fiscal_month_consecutive
	FROM vw_dim_gm_date_master
	WHERE date_key = TO_CHAR(date_sub(GETDATE(), 1), 'yyyymmdd')
	GROUP BY  fiscal_month_consecutive
), dim_date_monthly AS
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
) , fact AS
(
	SELECT  fiscal_year
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
	       ,new_prod_flag                                                                     AS is_new_product_flag
	       ,CASE WHEN business_area_name = '零售' AND customer_group_3_name IN ('NKA','RKA','LKA') THEN customer_group_name
	             WHEN business_area_name = '餐饮' AND customer_group_3_name = '直营' THEN customer_group_name
	             WHEN business_area_name = '电商' THEN customer_group_name  ELSE payer_name END AS customer_name
	       ,payer_name -- 2025/2/12 新加
	       ,product_flavour
	       ,is_top_dt_customer
	       ,CAST(CAST(stat_weight AS BIGINT) AS STRING) || stat_weight_unit_name              AS stat_weight
	       ,SUM(sellin_case)                                                                  AS cases
	       ,SUM(sellin_gsv)                                                                   AS gsv_comp
	       ,SUM(sellin_case_ly)                                                               AS cases_ly
	       ,SUM(sellin_gsv_ly)                                                                AS gsv_comp_ly
	       ,SUM(sellin_le_case)                                                               AS le_case_org
	       ,SUM(sellin_le_gsv)*1e3                                                            AS le_gsv_org
	       ,SUM(sellin_bonus_target_case)                                                     AS st_case_org
	       ,SUM(sellin_bonus_target_gsv)*1e3                                                  AS st_gsv_org
	       ,SUM(0)                                                                            AS sp_case_org
	       ,SUM(0)                                                                            AS sp_gsv_org
	       ,SUM(0)                                                                            AS le_case_customer
	       ,SUM(0)*1e3                                                                        AS le_gsv_customer
	       ,SUM(0)                                                                            AS sp_case_customer
	       ,SUM(0)*1e3                                                                        AS sp_gsv_customer
	       ,SUM(0)                                                                            AS st_case_customer
	       ,SUM(0)*1e3                                                                        AS st_gsv_customer
	       ,SUM(0)                                                                            AS le_case_product
	       ,SUM(0)*1e3                                                                        AS le_gsv_product
	       ,0                                                                                 AS sp_case_product
	       ,0                                                                                 AS sp_gsv_product
	       ,SUM(stock_case)                                                                   AS stock_case
	       ,SUM(stock_gsv)                                                                    AS stock_gsv
	       ,SUM(stock_case_ly)                                                                AS stock_case_ly
	       ,SUM(stock_gsv_ly)                                                                 AS stock_gsv_ly
	       ,SUM(sellout_past_28days_case)/28                                                  AS sellout_past_case
	       ,SUM(sellout_past_28days_gsv)/28                                                   AS sellout_past_gsv
	       ,SUM(sellout_next_28days_case)/28                                                  AS sellout_next_case
	       ,SUM(sellout_next_28days_gsv)/28                                                   AS sellout_next_gsv
	       ,SUM(sellout_past_28days_case_ly)/28                                               AS sellout_past_case_ly
	       ,SUM(sellout_past_28days_gsv_ly)/28                                                AS sellout_past_gsv_ly
	       ,SUM(sellout_next_28days_case_ly)/28                                               AS sellout_next_case_ly
	       ,SUM(sellout_next_28days_gsv_ly)/28                                                AS sellout_next_gsv_ly
	       ,SUM(sellout_case)                                                                 AS sellout_case
	       ,SUM(sellout_gsv)                                                                  AS sellout_gsv
	       ,SUM(sellout_case_ly)                                                              AS sellout_case_ly
	       ,SUM(sellout_gsv_ly)                                                               AS sellout_gsv_ly
	       ,SUM(sellout_le_case)                                                              AS sellout_le_case
	       ,SUM(sellout_le_gsv)                                                               AS sellout_le_gsv
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	GROUP BY  fiscal_year
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
	         ,new_prod_flag
	         ,CAST(CAST(stat_weight AS BIGINT) AS STRING) || stat_weight_unit_name
	         ,CASE WHEN business_area_name = '零售' AND customer_group_3_name IN ('NKA','RKA','LKA') THEN customer_group_name
	             WHEN business_area_name = '餐饮' AND customer_group_3_name = '直营' THEN customer_group_name
	             WHEN business_area_name = '电商' THEN customer_group_name  ELSE payer_name END
	         ,payer_name -- 2025/2/12 新加
	         ,product_flavour
	         ,is_top_dt_customer
), fact_multi AS
(
	SELECT  ''  AS level_0
	       ,''  AS level_1
	       ,''  AS level_2
	       ,'Y' AS data_type
	       ,t.*
	FROM fact AS t
	WHERE business_area_name IN ('零售', '电商', '餐饮') 
)
SELECT  t1.*
       ,CASE WHEN is_top_dt_customer = 'Y' or (customer_group_3_name = 'NKA' AND customer_name NOT IN ('others','CVS','未分配','家乐福')) THEN customer_name  ELSE 'others' END AS top_customer_name
       ,CASE WHEN is_top_dt_customer = 'Y' AND customer_name is not null THEN 'B'
             WHEN (customer_group_3_name = 'NKA' AND customer_name NOT IN ('others','CVS','未分配','家乐福')) AND customer_name is not null THEN 'A'  ELSE 'Z' END AS customer_name_sort
       ,t2.fiscal_quarter
       ,t2.fiscal_yp
       ,t2.fiscal_year_month
       ,t2.fiscal_month_conse
       ,t2.fiscal_quarter_conse
       ,t2.mtd_end
       ,t2.qtd_end
       ,t2.ytd_end
       ,t3.mtd_time_pasting
       ,t3.qtd_time_pasting
       ,t3.ytd_time_pasting
       ,'Y' AS act_month_end_filter
FROM fact_multi AS t1
LEFT JOIN dim_date_monthly AS t2
ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month
LEFT JOIN time_past AS t3
ON t2.fiscal_year = t3.fiscal_year AND t2.fiscal_month = t3.fiscal_month
WHERE t2.fiscal_year >= 2024
AND product_brand_name IN ('哈根达斯'，'湾仔码头')
AND nvl(sales_district_name, '') NOT IN ('达上', '未匹配')
AND nvl(cases, 0)+nvl(cases_ly, 0)+nvl(sellout_case, 0)+nvl(sellout_gsv_ly, 0)+nvl(sellout_past_case, 0)+nvl(sellout_next_case, 0)+nvl(le_case_org, 0)+nvl(st_case_org, 0)+NVL(sellout_le_case, 0) <> 0 -- 去掉所有都是0的数据行
