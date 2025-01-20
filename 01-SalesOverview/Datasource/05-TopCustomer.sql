WITH fact AS
(
	SELECT  fiscal_year
	       ,fiscal_quarter
	       ,fiscal_month
	       ,business_area_name
	       ,product_brand_name
	       ,customer_group_3_name
	       ,payer_cd
	       ,payer_name
	       ,SUM(sellin_case)              AS cases
	       ,SUM(sellin_gsv)               AS gsv
	       ,SUM(sellin_case_ly)           AS case_ly
	       ,SUM(sellin_gsv_ly)            AS gsv_ly
	       ,SUM(le_case)                  AS le_case
	       ,SUM(le_gsv)                   AS le_gsv
	       ,SUM(bonus_target_case)        AS st_case
	       ,SUM(bonus_target_gsv)         AS st_gsv
	       ,SUM(stock_case)               AS stock_case
	       ,SUM(stock_gsv)                AS stock_gsv
	       ,SUM(sellout_past_28days_case) AS sellout_past_28days_case
	       ,SUM(sellout_past_28days_gsv)  AS sellout_past_28days_gsv
	FROM tb_top_dt_sales_monthly_flat
	WHERE mt <> ''
	GROUP BY  fiscal_year
	         ,fiscal_quarter
	         ,fiscal_month
	         ,business_area_name
	         ,product_brand_name
	         ,customer_group_3_name
	         ,payer_cd
	         ,payer_name
), dim_date_monthly AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,fiscal_yp
	       ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2)) AS fiscal_year_month
	       ,fiscal_month_consecutive as fiscal_month_conse
	       ,fiscal_quarter_consecutive as fiscal_quarter_conse
	       ,MAX(end_date_of_fiscal_month)                                    AS mtd_end
	       ,MAX(end_date_of_fiscal_quarter)                                  AS qtd_end
	       ,MAX(end_date_of_fiscal_year)                                     AS ytd_end
	FROM tb_gm_date_master_dim
	GROUP BY  fiscal_year
	         ,fiscal_month
	         ,fiscal_quarter
	         ,fiscal_yp
	         ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2))
	         ,fiscal_month_consecutive
	         ,fiscal_quarter_consecutive
), time_past AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,MAX(round(time_pasting_rate_of_month,4))   AS mtd_time_pasting
	       ,MAX(round(time_pasting_rate_of_quarter,4)) AS qtd_time_pasting
	       ,MAX(round(time_pasting_rate_of_year,4))    AS ytd_time_pasting
	FROM tb_gm_date_master_dim
	WHERE fiscal_year >= 2022
	AND date_key < TO_CHAR(GETDATE(), 'yyyymmdd')
	GROUP BY  fiscal_year
	         ,fiscal_month
) , time_past_row AS
(
	SELECT  'MTD'            AS xtd_type
	       ,fiscal_year
	       ,fiscal_month
	       ,mtd_time_pasting AS time_pasting
	FROM time_past
	UNION ALL
	SELECT  'QTD'            AS xtd_type
	       ,fiscal_year
	       ,fiscal_month
	       ,qtd_time_pasting AS time_pasting
	FROM time_past
	UNION ALL
	SELECT  'YTD'            AS xtd_type
	       ,fiscal_year
	       ,fiscal_month
	       ,ytd_time_pasting AS time_pasting
	FROM time_past
) , ytd AS
(
	SELECT  'YTD'                                                                                 AS xtd_type
	       ,t2.fiscal_year
	       ,t2.fiscal_month
	       ,t1.business_area_name
	       ,t1.product_brand_name
	       ,t1.customer_group_3_name
	       ,t1.payer_cd
	       ,t1.payer_name
	       ,SUM(t1.cases)                                                                         AS cases
	       ,SUM(t1.gsv)                                                                           AS gsv
	       ,SUM(t1.case_ly)                                                                       AS case_ly
	       ,SUM(t1.gsv_ly)                                                                        AS gsv_ly
	       ,SUM(t1.le_case)                                                                       AS le_case
	       ,SUM(t1.le_gsv)                                                                        AS le_gsv
	       ,SUM(t1.st_case)                                                                       AS st_case
	       ,SUM(t1.st_gsv)                                                                        AS st_gsv
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN t1.stock_case end)               AS stock_case
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN t1.stock_gsv end)                AS stock_gsv
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN t1.sellout_past_28days_case end) AS sellout_past_28days_case
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN t1.sellout_past_28days_gsv end)  AS sellout_past_28days_gsv
	FROM fact t1
	LEFT JOIN dim_date_monthly t2
	ON t1.fiscal_year = t2.fiscal_year
	WHERE t1.fiscal_month <= t2.fiscal_month
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_month
	         ,t1.business_area_name
	         ,t1.product_brand_name
	         ,t1.customer_group_3_name
	         ,t1.payer_cd
	         ,t1.payer_name
), qtd_act AS
(
	SELECT  'QTD'                                                                                 AS xtd_type
	       ,t2.fiscal_year
	       ,t2.fiscal_month
	       ,t1.business_area_name
	       ,t1.product_brand_name
	       ,t1.customer_group_3_name
	       ,t1.payer_cd
	       ,t1.payer_name
	       ,SUM(t1.cases)                                                                         AS cases
	       ,SUM(t1.gsv)                                                                           AS gsv
	       ,SUM(t1.case_ly)                                                                       AS case_ly
	       ,SUM(t1.gsv_ly)                                                                        AS gsv_ly
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN t1.stock_case end)               AS stock_case
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN t1.stock_gsv end)                AS stock_gsv
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN t1.sellout_past_28days_case end) AS sellout_past_28days_case
	       ,SUM(case WHEN t1.fiscal_month = t2.fiscal_month THEN t1.sellout_past_28days_gsv end)  AS sellout_past_28days_gsv
	FROM fact t1
	LEFT JOIN dim_date_monthly t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_quarter = t2.fiscal_quarter
	WHERE t1.fiscal_month <= t2.fiscal_month
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_month
	         ,t1.business_area_name
	         ,t1.product_brand_name
	         ,t1.customer_group_3_name
	         ,t1.payer_cd
	         ,t1.payer_name
) , qtd_target AS
(
	SELECT  'QTD'           AS xtd_type
	       ,t2.fiscal_year
	       ,t2.fiscal_month
	       ,t1.business_area_name
	       ,t1.product_brand_name
	       ,t1.customer_group_3_name
	       ,t1.payer_cd
	       ,t1.payer_name
	       ,SUM(t1.le_case) AS le_case
	       ,SUM(t1.le_gsv)  AS le_gsv
	       ,SUM(t1.st_case) AS st_case
	       ,SUM(t1.st_gsv)  AS st_gsv
	FROM fact t1
	LEFT JOIN dim_date_monthly t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_quarter = t2.fiscal_quarter
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_month
	         ,t1.business_area_name
	         ,t1.product_brand_name
	         ,t1.customer_group_3_name
	         ,t1.payer_cd
	         ,t1.payer_name
), fact_union AS
(
	SELECT  'MTD' AS xtd_type
	       ,t1.fiscal_year
	       ,t1.fiscal_month
	       ,t1.business_area_name
	       ,t1.product_brand_name
	       ,t1.customer_group_3_name
	       ,t1.payer_cd
	       ,t1.payer_name
	       ,t1.cases
	       ,t1.gsv
	       ,t1.case_ly
	       ,t1.gsv_ly
	       ,t1.stock_case
	       ,t1.stock_gsv
	       ,t1.sellout_past_28days_case
	       ,t1.sellout_past_28days_gsv
	       ,t1.le_case
	       ,t1.le_gsv
	       ,t1.st_case
	       ,t1.st_gsv
	FROM fact t1
	UNION ALL
	SELECT  *
	FROM ytd
	UNION ALL
	SELECT  t1.*
	       ,t2.le_case
	       ,t2.le_gsv
	       ,t2.st_case
	       ,t2.st_gsv
	FROM qtd_act t1
	LEFT JOIN qtd_target t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month AND t1.product_brand_name = t2.product_brand_name AND t1.business_area_name = t2.business_area_name
)
SELECT  t1.*
       ,t2.fiscal_quarter
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
ON t2.fiscal_year = t3.fiscal_year AND t2.fiscal_month = t3.fiscal_month AND t1.xtd_type = t3.xtd_type
WHERE t1.fiscal_year >= 2025
AND t1.product_brand_name IN ('哈根达斯', '湾仔码头')