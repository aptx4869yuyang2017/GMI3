WITH dim_date_monthly AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,fiscal_yp
	       ,fiscal_month_show
	       ,fiscal_year_show
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
	         ,fiscal_month_show
	         ,fiscal_year_show
	         ,CONCAT( fiscal_year_show,' ',fiscal_month_show)
	         ,fiscal_month_consecutive
	         ,fiscal_quarter_consecutive
), cte_year_max AS
(
	SELECT  fiscal_year
	       ,MAX(fiscal_month_consecutive)   AS year_max_fiscal_month_conse
	       ,MAX(fiscal_quarter_consecutive) AS year_max_fiscal_quarter_conse
	FROM tb_gm_date_master_dim
	WHERE date_key <= TO_CHAR( (
	SELECT  to_date( substring(MAX(created_dt),1,10),'yyyy-mm-dd' )
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''), 'yyyymmdd' )
	GROUP BY  fiscal_year
), cte_current AS
(
	SELECT  0                               AS join_key
	       ,MAX(fiscal_month_consecutive)   AS current_fiscal_month_conse
	       ,MAX(fiscal_quarter_consecutive) AS current_fiscal_quarter_conse
	       ,MAX(fiscal_year)                AS current_fiscal_year
	FROM tb_gm_date_master_dim
	WHERE date_key <= TO_CHAR( (
	SELECT  to_date( substring(MAX(created_dt),1,10),'yyyy-mm-dd' )
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''), 'yyyymmdd' ) 
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
	       ,new_prod_flag                                                                                                                      AS is_new_product_flag
	       ,CASE WHEN business_area_name = '零售' AND customer_group_3_name IN ('NKA','RKA','LKA') THEN customer_group_name
	             WHEN business_area_name = '餐饮' AND customer_group_3_name = '直营' THEN customer_group_name
	             WHEN business_area_name = '电商' THEN customer_group_name  ELSE payer_name END                                                  AS customer_name
	       ,payer_name
           ,payer_cd
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
	       ,0                                                                                                                                  AS join_key
	       ,MAX(created_dt)                                                                                                                    AS created_dt
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt >= '202401'
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
             ,payer_cd
	         ,product_flavour
	         ,is_top_dt_customer
)
SELECT  t1.fiscal_year
       ,t1.fiscal_month
       ,t1.product_brand_name
       ,t1.business_area_name
       ,nvl(t1.sales_district_name,'')                                                 AS sales_district_name
       ,t1.customer_group_3_name
       ,t1.customer_group_2_name
       ,t1.customer_group_5_name
       ,t1.customer_group_name
       ,t1.product_category_name
       ,t1.product_midcategory_name
       ,t1.product_subcategory_name
       ,t1.product_strategy
       ,t1.product_cate5_name
       ,t1.is_new_product_flag
       ,t1.customer_name
       ,t1.payer_name
       ,t1.payer_cd
       ,t1.product_flavour
       ,t1.is_top_dt_customer
       ,t1.stat_weight
       ,t1.cases
       ,t1.gsv_comp
       ,t1.cases_ly
       ,t1.gsv_comp_ly
       ,t1.le_case_org
       ,t1.le_gsv_org
       ,t1.st_case_org
       ,t1.st_gsv_org
       ,t1.stock_case
       ,t1.stock_gsv
       ,t1.stock_case_ly
       ,t1.stock_gsv_ly
       ,t1.sellout_past_case
       ,t1.sellout_past_gsv
       ,t1.sellout_next_case
       ,t1.sellout_next_gsv
       ,t1.sellout_past_case_ly
       ,t1.sellout_past_gsv_ly
       ,t1.sellout_next_case_ly
       ,t1.sellout_next_gsv_ly
       ,t1.sellout_case
       ,t1.sellout_gsv
       ,t1.sellout_case_ly
       ,t1.sellout_gsv_ly
       ,t1.sellout_le_case
       ,t1.sellout_le_gsv
       ,t1.sellout_case_incl_promotion
       ,t1.sellout_gsv_incl_promotion
       ,t1.sellout_case_incl_promotion_ly
       ,t1.sellout_gsv_incl_promotion_ly
       ,CASE WHEN is_top_dt_customer = 'Y' or ( customer_group_3_name = 'NKA' AND customer_name NOT IN ( 'others','CVS','未分配','家乐福' ) ) THEN customer_name  ELSE 'others' END AS top_customer_name
       ,CASE WHEN is_top_dt_customer = 'Y' AND customer_name is not null THEN 'B'
             WHEN ( customer_group_3_name = 'NKA' AND customer_name NOT IN ( 'others','CVS','未分配','家乐福' ) ) AND customer_name is not null THEN 'A'  ELSE 'Z' END AS customer_name_sort
       ,t2.fiscal_quarter
       ,t2.fiscal_yp
       ,t2.fiscal_year_month
       ,t2.fiscal_month_conse
       ,t2.fiscal_quarter_conse
       ,t2.fiscal_month_show
       ,t2.fiscal_year_show
       ,t3.year_max_fiscal_month_conse                                                 AS max_fiscal_month_conse
       ,t3.year_max_fiscal_quarter_conse                                               AS max_fiscal_quarter_conse
       ,t4.current_fiscal_month_conse                                                  AS current_fiscal_month_conse
       ,t4.current_fiscal_quarter_conse                                                AS current_fiscal_quarter_conse
       ,t4.current_fiscal_year                                                         AS current_fiscal_year
       ,t2.mtd_time_pasting
       ,t2.qtd_time_pasting
       ,t2.ytd_time_pasting
       ,cast(to_date(substring(t1.created_dt,1,10),'yyyy-mm-dd') AS date)              AS created_dt
       ,cast(date_add(to_date(substring(t1.created_dt,1,10),'yyyy-mm-dd'),-1) AS date) AS create_dt_yesterday
FROM fact AS t1
LEFT JOIN dim_date_monthly AS t2
ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month
LEFT JOIN cte_year_max AS t3
ON t1.fiscal_year = t3.fiscal_year
LEFT JOIN cte_current AS t4
ON t4.join_key = t1.join_key
WHERE t2.fiscal_year >= 2024
AND product_brand_name IN ( '哈根达斯' , '湾仔码头' )
-- AND nvl(sales_district_name, '') NOT IN ( '达上', '未匹配', '未分配' )
-- AND nvl(customer_group_3_name, '') NOT IN ( '未分配' )
AND not(t2.fiscal_month_conse <= (
SELECT  MAX(year_max_fiscal_month_conse)
FROM cte_year_max) AND nvl(cases, 0) = 0 AND nvl(gsv_comp, 0) = 0 AND nvl(cases_ly, 0) = 0 AND nvl(gsv_comp_ly, 0) = 0 AND nvl(le_case_org, 0) = 0 AND nvl(le_gsv_org, 0) = 0 AND nvl(st_case_org, 0) = 0 AND nvl(st_gsv_org, 0) = 0 AND nvl(stock_case, 0) = 0 AND nvl(stock_gsv, 0) = 0 AND nvl(stock_case_ly, 0) = 0 AND nvl(stock_gsv_ly, 0) = 0 AND nvl(sellout_past_case, 0) = 0 AND nvl(sellout_past_gsv, 0) = 0 AND nvl(sellout_next_case, 0) = 0 AND nvl(sellout_next_gsv, 0) = 0 AND nvl(sellout_past_case_ly, 0) = 0 AND nvl(sellout_past_gsv_ly, 0) = 0 AND nvl(sellout_next_case_ly, 0) = 0 AND nvl(sellout_next_gsv_ly, 0) = 0 AND nvl(sellout_case, 0) = 0 AND nvl(sellout_gsv, 0) = 0 AND nvl(sellout_case_ly, 0) = 0 AND nvl(sellout_gsv_ly, 0) = 0 AND nvl(sellout_le_case, 0) = 0 AND nvl(sellout_le_gsv, 0) = 0 AND nvl(sellout_case_incl_promotion, 0) = 0 AND nvl(sellout_gsv_incl_promotion, 0) = 0 AND nvl(sellout_case_incl_promotion_ly, 0) = 0 AND nvl(sellout_gsv_incl_promotion_ly, 0) = 0)