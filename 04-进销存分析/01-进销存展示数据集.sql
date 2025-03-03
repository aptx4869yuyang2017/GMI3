WITH cte_current_fiscal_year AS
(
	SELECT  MAX(fiscal_year ) AS currenct_fiscal_year
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> '' 
), cte_sellin AS
(
	SELECT  'History Act'     AS data_label
	       ,'Month'           AS sub_year_label
	       ,'Sell in'         AS theme_level
	       ,fiscal_year       AS year_level
	       ,fiscal_month_show AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellin_case)  AS case_value
	       ,SUM(sellin_gsv)   AS gsv_value
	       ,0                 AS case_value_2
	       ,0                 AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year < (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year
	         ,fiscal_month_show
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'History Act'    AS data_label
	       ,'Quarter'        AS sub_year_label
	       ,'Sell in'        AS theme_level
	       ,fiscal_year      AS year_level
	       ,fiscal_quarter   AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellin_case) AS case_value
	       ,SUM(sellin_gsv)  AS gsv_value
	       ,0                AS case_value_2
	       ,0                AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year < (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year
	         ,fiscal_quarter
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY Act'              AS data_label
	       ,'Month'               AS sub_year_label
	       ,'Sell in'             AS theme_level
	       ,fiscal_year || ' Act' AS year_level
	       ,fiscal_month_show     AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellin_case)      AS case_value
	       ,SUM(sellin_gsv)       AS gsv_value
	       ,0                     AS case_value_2
	       ,0                     AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' Act'
	         ,fiscal_month_show
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY Act'              AS data_label
	       ,'Quarter'             AS sub_year_label
	       ,'Sell in'             AS theme_level
	       ,fiscal_year || ' Act' AS year_level
	       ,fiscal_quarter        AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellin_case)      AS case_value
	       ,SUM(sellin_gsv)       AS gsv_value
	       ,0                     AS case_value_2
	       ,0                     AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' Act'
	         ,fiscal_quarter
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'LY Act'              AS data_label
	       ,'Month'               AS sub_year_label
	       ,'Sell in'             AS theme_level
	       ,fiscal_year || ' YOY' AS year_level
	       ,fiscal_month_show     AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellin_case)      AS case_value
	       ,SUM(sellin_gsv)       AS gsv_value
	       ,SUM(sellin_case_ly)   AS case_value_2
	       ,SUM(sellin_gsv_ly)    AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' YOY'
	         ,fiscal_month_show
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'LY Act'              AS data_label
	       ,'Quarter'             AS sub_year_label
	       ,'Sell in'             AS theme_level
	       ,fiscal_year || ' YOY' AS year_level
	       ,fiscal_quarter        AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellin_case)      AS case_value
	       ,SUM(sellin_gsv)       AS gsv_value
	       ,SUM(sellin_case_ly)   AS case_value_2
	       ,SUM(sellin_gsv_ly)    AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' YOY'
	         ,fiscal_quarter
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY LE'              AS data_label
	       ,'Month'              AS sub_year_label
	       ,'Sell in'            AS theme_level
	       ,fiscal_year || ' LE' AS year_level
	       ,fiscal_month_show    AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellin_le_case)  AS case_value
	       ,SUM(sellin_le_gsv)   AS gsv_value
	       ,0                    AS case_value_2
	       ,0                    AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' LE'
	         ,fiscal_month_show
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY LE'              AS data_label
	       ,'Quarter'            AS sub_year_label
	       ,'Sell in'            AS theme_level
	       ,fiscal_year || ' LE' AS year_level
	       ,fiscal_quarter       AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellin_le_case)  AS case_value
	       ,SUM(sellin_le_gsv)   AS gsv_value
	       ,0                    AS case_value_2
	       ,0                    AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' LE'
	         ,fiscal_quarter
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY ST'                        AS data_label
	       ,'Month'                        AS sub_year_label
	       ,'Sell in'                      AS theme_level
	       ,fiscal_year || ' Bonus Target' AS year_level
	       ,fiscal_month_show              AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellin_bonus_target_case)  AS case_value
	       ,SUM(sellin_bonus_target_gsv)   AS gsv_value
	       ,0                              AS case_value_2
	       ,0                              AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' Bonus Target'
	         ,fiscal_month_show
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY ST'                        AS data_label
	       ,'Quarter'                      AS sub_year_label
	       ,'Sell in'                      AS theme_level
	       ,fiscal_year || ' Bonus Target' AS year_level
	       ,fiscal_quarter                 AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellin_bonus_target_case)  AS case_value
	       ,SUM(sellin_bonus_target_gsv)   AS gsv_value
	       ,0                              AS case_value_2
	       ,0                              AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' Bonus Target'
	         ,fiscal_quarter
	         ,business_area_name
	         ,sales_district_name
)
SELECT  *
FROM cte_sellin