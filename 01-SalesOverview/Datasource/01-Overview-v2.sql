WITH fact AS
(
	SELECT  fiscal_year
	       ,fiscal_quarter
	       ,fiscal_month
	       ,business_area_name
	       ,product_brand_name
	       ,SUM(sellin_case)              AS cases
	       ,SUM(sellin_gsv)               AS gsv
	       ,SUM(sellin_case_ly)           AS case_ly
	       ,SUM(sellin_gsv_ly)            AS gsv_ly
	       ,SUM(sellin_le_case)           AS le_case
	       ,SUM(sellin_le_gsv)            AS le_gsv
	       ,SUM(sellin_sp_case)           AS sp_case
	       ,SUM(sellin_sp_gsv)            AS sp_gsv
	       ,SUM(sellin_bonus_target_case) AS st_case
	       ,SUM(sellin_bonus_target_gsv ) AS st_gsv
	FROM tb_sellin_coverpage_daily_flat
	WHERE dt <> ''
	GROUP BY  fiscal_year
	         ,fiscal_quarter
	         ,fiscal_month
	         ,business_area_name
	         ,product_brand_name
), dim_date_monthly AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,fiscal_yp
	       ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2)) AS fiscal_year_month
	       ,int(fiscal_year * 12 + fiscal_month)                             AS fiscal_month_conse
	       ,int(fiscal_year * 4 + int(SUBSTRING(fiscal_quarter,-1)))         AS fiscal_quarter_conse
	FROM vw_dim_gm_date_master
	GROUP BY  fiscal_year
	         ,fiscal_month
	         ,fiscal_quarter
	         ,fiscal_yp
	         ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2))
	         ,int(fiscal_year * 12 + fiscal_month)
	         ,int(fiscal_year * 4 + int(SUBSTRING(fiscal_quarter,-1)))
), time_past AS
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
	SELECT  'YTD'           AS xtd_type
	       ,t2.fiscal_year
	       ,t2.fiscal_month
	       ,t1.business_area_name
	       ,t1.product_brand_name
	       ,t1.SUM(cases)   AS cases
	       ,t1.SUM(gsv)     AS gsv
	       ,t1.SUM(case_ly) AS case_ly
	       ,t1.SUM(gsv_ly)  AS gsv_ly
	       ,t1.SUM(le_case) AS le_case
	       ,t1.SUM(le_gsv)  AS le_gsv
	       ,t1.SUM(sp_case) AS sp_case
	       ,t1.SUM(sp_gsv)  AS sp_gsv
	       ,t1.SUM(st_case) AS st_case
	       ,t1.SUM(st_gsv)  AS st_gsv
	FROM fact t1
	LEFT JOIN dim_date_monthly t2
	ON t1.fiscal_year = t2.fiscal_year
	WHERE t1.fiscal_month <= t2.fiscal_month
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_month
	         ,t1.business_area_name
	         ,t1.product_brand_name
), qtd_act AS
(
	SELECT  'QTD'           AS xtd_type
	       ,t2.fiscal_year
	       ,t2.fiscal_month
	       ,t1.business_area_name
	       ,t1.product_brand_name
	       ,t1.SUM(cases)   AS cases
	       ,t1.SUM(gsv)     AS gsv
	       ,t1.SUM(case_ly) AS case_ly
	       ,t1.SUM(gsv_ly)  AS gsv_ly
	FROM fact t1
	LEFT JOIN dim_date_monthly t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_quarter = t2.fiscal_quarter
	WHERE t1.fiscal_month <= t2.fiscal_month
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_month
	         ,t1.business_area_name
	         ,t1.product_brand_name
) , qtd_target AS
(
	SELECT  'QTD'           AS xtd_type
	       ,t2.fiscal_year
	       ,t2.fiscal_month
	       ,t1.business_area_name
	       ,t1.product_brand_name
	       ,t1.SUM(le_case) AS le_case
	       ,t1.SUM(le_gsv)  AS le_gsv
	       ,t1.SUM(sp_case) AS sp_case
	       ,t1.SUM(sp_gsv)  AS sp_gsv
	       ,t1.SUM(st_case) AS st_case
	       ,t1.SUM(st_gsv)  AS st_gsv
	FROM fact t1
	LEFT JOIN dim_date_monthly t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_quarter = t2.fiscal_quarter
	GROUP BY  t2.fiscal_year
	         ,t2.fiscal_month
	         ,t1.business_area_name
	         ,t1.product_brand_name
), fact_union AS
(
	SELECT  'MTD' AS xtd_type
	       ,t1.fiscal_year
	       ,t1.fiscal_month
	       ,t1.business_area_name
	       ,t1.product_brand_name
	       ,t1.cases
	       ,t1.gsv
	       ,t1.case_ly
	       ,t1.gsv_ly
	       ,t1.le_case
	       ,t1.le_gsv
	       ,t1.sp_case
	       ,t1.sp_gsv
	       ,t1.st_case
	       ,t1.st_gsv
	FROM fact t1
	UNION ALL
	SELECT  xtd_type
	       ,fiscal_year
	       ,fiscal_month
	       ,business_area_name
	       ,product_brand_name
	       ,cases
	       ,gsv
	       ,case_ly
	       ,gsv_ly
	       ,le_case
	       ,le_gsv
	       ,sp_case
	       ,sp_gsv
	       ,st_case
	       ,st_gsv
	FROM ytd
	UNION ALL
	SELECT  t1.xtd_type
	       ,t1.fiscal_year
	       ,t1.fiscal_month
	       ,t1.business_area_name
	       ,t1.product_brand_name
	       ,t1.cases
	       ,t1.gsv
	       ,t1.case_ly
	       ,t1.gsv_ly
	       ,t2.le_case
	       ,t2.le_gsv
	       ,t2.sp_case
	       ,t2.sp_gsv
	       ,t2.st_case
	       ,t2.st_gsv
	FROM qtd_act t1
	LEFT JOIN qtd_target t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month AND t1.product_brand_name = t2.product_brand_name AND t1.business_area_name = t2.business_area_name
)
SELECT  t1.xtd_type
       ,t1.fiscal_year
       ,t1.fiscal_month
       ,t1.business_area_name
       ,t1.product_brand_name
       ,t1.cases
       ,t1.gsv
       ,t1.case_ly
       ,t1.gsv_ly
       ,t1.le_case
       ,t1.le_gsv
       ,t1.sp_case
       ,t1.sp_gsv
       ,t1.st_case
       ,t1.st_gsv
       ,t2.fiscal_quarter
       ,t2.fiscal_yp
       ,t2.fiscal_year_month
       ,t2.fiscal_month_conse
       ,t2.fiscal_quarter_conse
       ,t3.time_pasting
FROM fact_union t1
LEFT JOIN dim_date_monthly AS t2
ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month
LEFT JOIN time_past_row AS t3
ON t2.fiscal_year = t3.fiscal_year AND t2.fiscal_month = t3.fiscal_month AND t1.xtd_type = t3.xtd_type
WHERE t1.fiscal_year >= 2025
AND t1.product_brand_name IN ('哈根达斯', '湾仔码头')