WITH cte_dim_date_monthly AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,fiscal_month_show
	       ,fiscal_year_show
	       ,CONCAT( fiscal_year_show,' ',fiscal_month_show) AS fiscal_year_month
	       ,fiscal_month_consecutive                        AS fiscal_month_conse
	       ,fiscal_quarter_consecutive                      AS fiscal_quarter_conse
	FROM tb_gm_date_master_dim
	GROUP BY  fiscal_year
	         ,fiscal_month
	         ,fiscal_quarter
	         ,fiscal_month_show
	         ,fiscal_year_show
	         ,CONCAT( fiscal_year_show,' ',fiscal_month_show)
	         ,fiscal_month_consecutive
	         ,fiscal_quarter_consecutive
) , cte_fact AS
(
	SELECT  fiscal_year
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
	       ,new_prod_flag
	       ,payer_name
	       ,payer_cd
	       ,product_flavour
	       ,is_top_dt_customer
	       ,stat_weight
	       ,stat_weight_unit_name
	       ,SUM(sellin_case)                    AS sellin_case
	       ,SUM(sellin_gsv)                     AS sellin_gsv
	       ,SUM(sellin_case_ly)                 AS sellin_case_ly
	       ,SUM(sellin_gsv_ly)                  AS sellin_gsv_ly
	       ,SUM(sellin_le_case)                 AS sellin_le_case
	       ,SUM(sellin_le_gsv)                  AS sellin_le_gsv
	       ,SUM(sellin_bonus_target_case)       AS sellin_bonus_target_case
	       ,SUM(sellin_bonus_target_gsv)        AS sellin_bonus_target_gsv
	       ,SUM(stock_case)                     AS stock_case
	       ,SUM(stock_gsv)                      AS stock_gsv
	       ,SUM(stock_case_ly)                  AS stock_case_ly
	       ,SUM(stock_gsv_ly)                   AS stock_gsv_ly
	       ,SUM(sellout_case)                   AS sellout_case
	       ,SUM(sellout_gsv)                    AS sellout_gsv
	       ,SUM(sellout_case_ly)                AS sellout_case_ly
	       ,SUM(sellout_gsv_ly)                 AS sellout_gsv_ly
	       ,SUM(sellout_le_case)                AS sellout_le_case
	       ,SUM(sellout_le_gsv)                 AS sellout_le_gsv
	       ,SUM(sellout_case_incl_promotion)    AS sellout_case_incl_promotion
	       ,SUM(sellout_gsv_incl_promotion)     AS sellout_gsv_incl_promotion
	       ,SUM(sellout_case_incl_promotion_ly) AS sellout_case_incl_promotion_ly
	       ,SUM(sellout_gsv_incl_promotion_ly)  AS sellout_gsv_incl_promotion_ly
	       ,MAX(created_dt)                     AS created_dt
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt >= '202401' -- AND business_area_name = '零售'
	-- AND customer_group_3_name IN ('经销商')
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
	         ,new_prod_flag
	         ,payer_name
	         ,payer_cd
	         ,product_flavour
	         ,is_top_dt_customer
	         ,stat_weight
	         ,stat_weight_unit_name
), cte_fact_ytd AS
(
	SELECT  'YTD'                               AS date_range_type
	       ,t2.fiscal_year
	       ,t2.fiscal_quarter
	       ,t2.fiscal_month
	       ,t1.product_brand_name
	       ,t1.business_area_name
	       ,t1.sales_district_name
	       ,t1.customer_group_3_name
	       ,t1.customer_group_2_name
	       ,t1.customer_group_5_name
	       ,t1.customer_group_name
	       ,t1.product_category_name
	       ,t1.product_midcategory_name
	       ,t1.product_subcategory_name
	       ,t1.product_strategy
	       ,t1.product_cate5_name
	       ,t1.new_prod_flag
	       ,t1.payer_name
	       ,t1.payer_cd
	       ,t1.product_flavour
	       ,t1.is_top_dt_customer
	       ,t1.stat_weight
	       ,t1.stat_weight_unit_name
	       ,SUM(sellin_case)                    AS sellin_case
	       ,SUM(sellin_gsv)                     AS sellin_gsv
	       ,SUM(sellin_case_ly)                 AS sellin_case_ly
	       ,SUM(sellin_gsv_ly)                  AS sellin_gsv_ly
	       ,SUM(sellin_le_case)                 AS sellin_le_case
	       ,SUM(sellin_le_gsv)                  AS sellin_le_gsv
	       ,SUM(sellin_bonus_target_case)       AS sellin_bonus_target_case
	       ,SUM(sellin_bonus_target_gsv)        AS sellin_bonus_target_gsv
	       ,SUM(stock_case)                     AS stock_case
	       ,SUM(stock_gsv)                      AS stock_gsv
	       ,SUM(stock_case_ly)                  AS stock_case_ly
	       ,SUM(stock_gsv_ly)                   AS stock_gsv_ly
	       ,SUM(sellout_case)                   AS sellout_case
	       ,SUM(sellout_gsv)                    AS sellout_gsv
	       ,SUM(sellout_case_ly)                AS sellout_case_ly
	       ,SUM(sellout_gsv_ly)                 AS sellout_gsv_ly
	       ,SUM(sellout_le_case)                AS sellout_le_case
	       ,SUM(sellout_le_gsv)                 AS sellout_le_gsv
	       ,SUM(sellout_case_incl_promotion)    AS sellout_case_incl_promotion
	       ,SUM(sellout_gsv_incl_promotion)     AS sellout_gsv_incl_promotion
	       ,SUM(sellout_case_incl_promotion_ly) AS sellout_case_incl_promotion_ly
	       ,SUM(sellout_gsv_incl_promotion_ly)  AS sellout_gsv_incl_promotion_ly
	       ,MAX(created_dt)                     AS created_dt
	FROM cte_fact t1
	LEFT JOIN cte_dim_date_monthly t2
	ON cast(t1.fiscal_year AS int) = cast(t2.fiscal_year AS int)
	WHERE t1.fiscal_month <= t2.fiscal_month
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_quarter
	         ,t2.fiscal_month
	         ,t1.product_brand_name
	         ,t1.business_area_name
	         ,t1.sales_district_name
	         ,t1.customer_group_3_name
	         ,t1.customer_group_2_name
	         ,t1.customer_group_5_name
	         ,t1.customer_group_name
	         ,t1.product_category_name
	         ,t1.product_midcategory_name
	         ,t1.product_subcategory_name
	         ,t1.product_strategy
	         ,t1.product_cate5_name
	         ,t1.new_prod_flag
	         ,t1.payer_name
	         ,t1.payer_cd
	         ,t1.product_flavour
	         ,t1.is_top_dt_customer
	         ,t1.stat_weight
	         ,t1.stat_weight_unit_name
) , cte_fact_qtd AS
(
	SELECT  'QTD'                               AS date_range_type
	       ,t2.fiscal_year
	       ,t2.fiscal_quarter
	       ,t2.fiscal_month
	       ,t1.product_brand_name
	       ,t1.business_area_name
	       ,t1.sales_district_name
	       ,t1.customer_group_3_name
	       ,t1.customer_group_2_name
	       ,t1.customer_group_5_name
	       ,t1.customer_group_name
	       ,t1.product_category_name
	       ,t1.product_midcategory_name
	       ,t1.product_subcategory_name
	       ,t1.product_strategy
	       ,t1.product_cate5_name
	       ,t1.new_prod_flag
	       ,t1.payer_name
	       ,t1.payer_cd
	       ,t1.product_flavour
	       ,t1.is_top_dt_customer
	       ,t1.stat_weight
	       ,t1.stat_weight_unit_name
	       ,SUM(sellin_case)                    AS sellin_case
	       ,SUM(sellin_gsv)                     AS sellin_gsv
	       ,SUM(sellin_case_ly)                 AS sellin_case_ly
	       ,SUM(sellin_gsv_ly)                  AS sellin_gsv_ly
	       ,SUM(sellin_le_case)                 AS sellin_le_case
	       ,SUM(sellin_le_gsv)                  AS sellin_le_gsv
	       ,SUM(sellin_bonus_target_case)       AS sellin_bonus_target_case
	       ,SUM(sellin_bonus_target_gsv)        AS sellin_bonus_target_gsv
	       ,SUM(stock_case)                     AS stock_case
	       ,SUM(stock_gsv)                      AS stock_gsv
	       ,SUM(stock_case_ly)                  AS stock_case_ly
	       ,SUM(stock_gsv_ly)                   AS stock_gsv_ly
	       ,SUM(sellout_case)                   AS sellout_case
	       ,SUM(sellout_gsv)                    AS sellout_gsv
	       ,SUM(sellout_case_ly)                AS sellout_case_ly
	       ,SUM(sellout_gsv_ly)                 AS sellout_gsv_ly
	       ,SUM(sellout_le_case)                AS sellout_le_case
	       ,SUM(sellout_le_gsv)                 AS sellout_le_gsv
	       ,SUM(sellout_case_incl_promotion)    AS sellout_case_incl_promotion
	       ,SUM(sellout_gsv_incl_promotion)     AS sellout_gsv_incl_promotion
	       ,SUM(sellout_case_incl_promotion_ly) AS sellout_case_incl_promotion_ly
	       ,SUM(sellout_gsv_incl_promotion_ly)  AS sellout_gsv_incl_promotion_ly
	       ,MAX(created_dt)                     AS created_dt
	FROM cte_fact t1
	LEFT JOIN cte_dim_date_monthly t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_quarter = t2.fiscal_quarter
	WHERE cast(t1.fiscal_month AS int) <= cast(t2.fiscal_month AS int)
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_quarter
	         ,t2.fiscal_month
	         ,t1.product_brand_name
	         ,t1.business_area_name
	         ,t1.sales_district_name
	         ,t1.customer_group_3_name
	         ,t1.customer_group_2_name
	         ,t1.customer_group_5_name
	         ,t1.customer_group_name
	         ,t1.product_category_name
	         ,t1.product_midcategory_name
	         ,t1.product_subcategory_name
	         ,t1.product_strategy
	         ,t1.product_cate5_name
	         ,t1.new_prod_flag
	         ,t1.payer_name
	         ,t1.payer_cd
	         ,t1.product_flavour
	         ,t1.is_top_dt_customer
	         ,t1.stat_weight
	         ,t1.stat_weight_unit_name
) , cte_union_t AS
(
	SELECT  'MTD' AS date_range_type
	       ,t1.*
	FROM cte_fact t1
	UNION ALL
	SELECT  *
	FROM cte_fact_qtd
	UNION ALL
	SELECT  *
	FROM cte_fact_ytd
)
SELECT  *
FROM cte_union_t