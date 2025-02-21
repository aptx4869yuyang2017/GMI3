WITH dim_date_monthly AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,fiscal_yp
	       ,CONCAT( fiscal_year_show,' ',fiscal_month_show) AS fiscal_year_month
	       ,fiscal_month_consecutive                        AS fiscal_month_conse
	       ,fiscal_quarter_consecutive                      AS fiscal_quarter_conse
	       ,round(MAX(time_pasting_rate_of_month),4)        AS mtd_time_pasting
	       ,round(MAX(time_pasting_rate_of_quarter),4)      AS qtd_time_pasting
	       ,round(MAX(time_pasting_rate_of_year),4)         AS ytd_time_pasting
	FROM tb_gm_date_master_dim
	GROUP BY  fiscal_year
	         ,fiscal_month
	         ,fiscal_quarter
	         ,fiscal_yp
	         ,CONCAT( fiscal_year_show,' ',fiscal_month_show)
	         ,fiscal_month_consecutive
	         ,fiscal_quarter_consecutive
), fact AS
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
	       ,new_prod_flag                                                                                                                      AS is_new_product_flag
	       ,CASE WHEN business_area_name = '零售' AND customer_group_3_name IN ('NKA','RKA','LKA') THEN customer_group_name
	             WHEN business_area_name = '餐饮' AND customer_group_3_name = '直营' THEN customer_group_name
	             WHEN business_area_name = '电商' THEN customer_group_name  ELSE payer_name END                                                  AS customer_name
	       ,payer_name
	       ,product_flavour
	       ,is_top_dt_customer
	       ,CASE WHEN stat_weight_unit_name <> '未匹配' THEN CAST(CAST(stat_weight AS BIGINT) AS STRING) || stat_weight_unit_name  ELSE '未匹配' END AS stat_weight
	       ,SUM(sellin_case)                                                                                                                   AS cases
	       ,SUM(sellin_gsv)                                                                                                                    AS gsv_comp
	       ,SUM(sellin_case_ly)                                                                                                                AS cases_ly
	       ,SUM(sellin_gsv_ly)                                                                                                                 AS gsv_comp_ly
	       ,SUM(sellin_le_case)                                                                                                                AS le_case_org
	       ,SUM(sellin_le_gsv) * 1e3                                                                                                           AS le_gsv_org
	       ,SUM(sellin_bonus_target_case)                                                                                                      AS st_case_org
	       ,SUM(sellin_bonus_target_gsv) * 1e3                                                                                                 AS st_gsv_org
	       ,SUM(stock_case)                                                                                                                    AS stock_case
	       ,SUM(stock_gsv)                                                                                                                     AS stock_gsv
	       ,SUM(stock_case_ly)                                                                                                                 AS stock_case_ly
	       ,SUM(stock_gsv_ly)                                                                                                                  AS stock_gsv_ly
	       ,SUM(sellout_past_28days_case) / 28                                                                                                 AS sellout_past_case
	       ,SUM(sellout_past_28days_gsv) / 28                                                                                                  AS sellout_past_gsv
	       ,SUM(sellout_next_28days_case) / 28                                                                                                 AS sellout_next_case
	       ,SUM(sellout_next_28days_gsv) / 28                                                                                                  AS sellout_next_gsv
	       ,SUM(sellout_past_28days_case_ly) / 28                                                                                              AS sellout_past_case_ly
	       ,SUM(sellout_past_28days_gsv_ly) / 28                                                                                               AS sellout_past_gsv_ly
	       ,SUM(sellout_next_28days_case_ly) / 28                                                                                              AS sellout_next_case_ly
	       ,SUM(sellout_next_28days_gsv_ly) / 28                                                                                               AS sellout_next_gsv_ly
	       ,SUM(sellout_case)                                                                                                                  AS sellout_case
	       ,SUM(sellout_gsv)                                                                                                                   AS sellout_gsv
	       ,SUM(sellout_case_ly)                                                                                                               AS sellout_case_ly
	       ,SUM(sellout_gsv_ly)                                                                                                                AS sellout_gsv_ly
	       ,SUM(sellout_le_case)                                                                                                               AS sellout_le_case
	       ,SUM(sellout_le_gsv)                                                                                                                AS sellout_le_gsv
	       ,SUM(sellout_case_incl_promotion)                                                                                                   AS sellout_case_incl_promotion
	       ,SUM(sellout_gsv_incl_promotion)                                                                                                    AS sellout_gsv_incl_promotion
	       ,SUM(sellout_case_incl_promotion_ly)                                                                                                AS sellout_case_incl_promotion_ly
	       ,SUM(sellout_gsv_incl_promotion_ly)                                                                                                 AS sellout_gsv_incl_promotion_ly
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
	         ,CASE WHEN stat_weight_unit_name <> '未匹配' THEN CAST(CAST(stat_weight AS BIGINT) AS STRING) || stat_weight_unit_name  ELSE '未匹配' END
	         ,CASE WHEN business_area_name = '零售' AND customer_group_3_name IN ('NKA','RKA','LKA') THEN customer_group_name
	             WHEN business_area_name = '餐饮' AND customer_group_3_name = '直营' THEN customer_group_name
	             WHEN business_area_name = '电商' THEN customer_group_name  ELSE payer_name END
	         ,payer_name
	         ,product_flavour
	         ,is_top_dt_customer
)
SELECT  t1.*
       ,CASE WHEN is_top_dt_customer = 'Y' or ( customer_group_3_name = 'NKA' AND customer_name NOT IN ( 'others','CVS','未分配','家乐福' ) ) THEN customer_name  ELSE 'others' END AS top_customer_name
       ,CASE WHEN is_top_dt_customer = 'Y' AND customer_name is not null THEN 'B'
             WHEN ( customer_group_3_name = 'NKA' AND customer_name NOT IN ( 'others','CVS','未分配','家乐福' ) ) AND customer_name is not null THEN 'A'  ELSE 'Z' END AS customer_name_sort
       ,t2.fiscal_quarter
       ,t2.fiscal_yp
       ,t2.fiscal_year_month
       ,t2.fiscal_month_conse
       ,t2.fiscal_quarter_conse
       ,t2.mtd_time_pasting
       ,t2.qtd_time_pasting
       ,t2.ytd_time_pasting
FROM fact AS t1
LEFT JOIN dim_date_monthly AS t2
ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month
WHERE t2.fiscal_year >= 2024
AND product_brand_name IN ( '哈根达斯' , '湾仔码头' )
AND nvl(sales_district_name, '') NOT IN ( '达上', '未匹配', '未分配' )
AND nvl(customer_group_3_name, '') NOT IN ( '未分配' )
AND not( nvl(cases, 0) = 0 AND nvl(gsv_comp, 0) = 0 AND nvl(cases_ly, 0) = 0 AND nvl(gsv_comp_ly, 0) = 0 AND nvl(le_case_org, 0) = 0 AND nvl(le_gsv_org, 0) = 0 AND nvl(st_case_org, 0) = 0 AND nvl(st_gsv_org, 0) = 0 AND nvl(stock_case, 0) = 0 AND nvl(stock_gsv, 0) = 0 AND nvl(stock_case_ly, 0) = 0 AND nvl(stock_gsv_ly, 0) = 0 AND nvl(sellout_past_case, 0) = 0 AND nvl(sellout_past_gsv, 0) = 0 AND nvl(sellout_next_case, 0) = 0 AND nvl(sellout_next_gsv, 0) = 0 AND nvl(sellout_past_case_ly, 0) = 0 AND nvl(sellout_past_gsv_ly, 0) = 0 AND nvl(sellout_next_case_ly, 0) = 0 AND nvl(sellout_next_gsv_ly, 0) = 0 AND nvl(sellout_case, 0) = 0 AND nvl(sellout_gsv, 0) = 0 AND nvl(sellout_case_ly, 0) = 0 AND nvl(sellout_gsv_ly, 0) = 0 AND nvl(sellout_le_case, 0) = 0 AND nvl(sellout_le_gsv, 0) = 0 )