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
), cte_sellout AS
(
	SELECT  'History Act'     AS data_label
	       ,'Month'           AS sub_year_label
	       ,'Sell out'        AS theme_level
	       ,fiscal_year       AS year_level
	       ,fiscal_month_show AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellout_case) AS case_value
	       ,SUM(sellout_gsv)  AS gsv_value
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
	SELECT  'History Act'     AS data_label
	       ,'Quarter'         AS sub_year_label
	       ,'Sell out'        AS theme_level
	       ,fiscal_year       AS year_level
	       ,fiscal_quarter    AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellout_case) AS case_value
	       ,SUM(sellout_gsv)  AS gsv_value
	       ,0                 AS case_value_2
	       ,0                 AS gsv_value_2
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
	       ,'Sell out'            AS theme_level
	       ,fiscal_year || ' Act' AS year_level
	       ,fiscal_month_show     AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellout_case)     AS case_value
	       ,SUM(sellout_gsv)      AS gsv_value
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
	       ,'Sell out'            AS theme_level
	       ,fiscal_year || ' Act' AS year_level
	       ,fiscal_quarter        AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellout_case)     AS case_value
	       ,SUM(sellout_gsv)      AS gsv_value
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
	       ,'Sell out'            AS theme_level
	       ,fiscal_year || ' YOY' AS year_level
	       ,fiscal_month_show     AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellout_case)     AS case_value
	       ,SUM(sellout_gsv)      AS gsv_value
	       ,SUM(sellout_case_ly)  AS case_value_2
	       ,SUM(sellout_gsv_ly)   AS gsv_value_2
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
	       ,'Sell out'            AS theme_level
	       ,fiscal_year || ' YOY' AS year_level
	       ,fiscal_quarter        AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellout_case)     AS case_value
	       ,SUM(sellout_gsv)      AS gsv_value
	       ,SUM(sellout_case_ly)  AS case_value_2
	       ,SUM(sellout_gsv_ly)   AS gsv_value_2
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
	       ,'Sell out'           AS theme_level
	       ,fiscal_year || ' LE' AS year_level
	       ,fiscal_month_show    AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellout_le_case) AS case_value
	       ,SUM(sellout_le_gsv)  AS gsv_value
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
	       ,'Sell out'           AS theme_level
	       ,fiscal_year || ' LE' AS year_level
	       ,fiscal_quarter       AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(sellout_le_case) AS case_value
	       ,SUM(sellout_le_gsv)  AS gsv_value
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
) , cte_inventory AS
(
	SELECT  'CY Inv'                     AS data_label
	       ,'Month'                      AS sub_year_label
	       ,'Inventory'                  AS theme_level
	       ,fiscal_year || ' Inv Latest' AS year_level
	       ,fiscal_month_show            AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(stock_case)              AS case_value
	       ,SUM(stock_gsv)               AS gsv_value
	       ,0                            AS case_value_2
	       ,0                            AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' Inv Latest'
	         ,fiscal_month_show
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY Inv'                     AS data_label
	       ,'Quarter'                    AS sub_year_label
	       ,'Inventory'                  AS theme_level
	       ,fiscal_year || ' Inv Latest' AS year_level
	       ,fiscal_quarter               AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(stock_case)              AS case_value
	       ,SUM(stock_gsv)               AS gsv_value
	       ,0                            AS case_value_2
	       ,0                            AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' Inv Latest'
	         ,fiscal_quarter
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY Inv'                   AS data_label
	       ,'Month'                    AS sub_year_label
	       ,'Inventory'                AS theme_level
	       ,fiscal_year || ' Inv Last' AS year_level
	       ,fiscal_month_show          AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(stock_case)            AS case_value
	       ,SUM(stock_gsv)             AS gsv_value
	       ,0                          AS case_value_2
	       ,0                          AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' Inv Last'
	         ,fiscal_month_show
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY Inv'                   AS data_label
	       ,'Quarter'                  AS sub_year_label
	       ,'Inventory'                AS theme_level
	       ,fiscal_year || ' Inv Last' AS year_level
	       ,fiscal_quarter             AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(stock_case)            AS case_value
	       ,SUM(stock_gsv)             AS gsv_value
	       ,0                          AS case_value_2
	       ,0                          AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' Inv Last'
	         ,fiscal_quarter
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY DOH'                      AS data_label
	       ,'Month'                       AS sub_year_label
	       ,'Inventory'                   AS theme_level
	       ,fiscal_year || ' DOH Latest'  AS year_level
	       ,fiscal_month_show             AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(stock_case)               AS case_value
	       ,SUM(stock_gsv)                AS gsv_value
	       ,SUM(sellout_next_28days_case) AS case_value_2
	       ,SUM(sellout_next_28days_gsv)  AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' DOH Latest'
	         ,fiscal_month_show
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY DOH'                      AS data_label
	       ,'Quarter'                     AS sub_year_label
	       ,'Inventory'                   AS theme_level
	       ,fiscal_year || ' DOH Latest'  AS year_level
	       ,fiscal_quarter                AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(stock_case)               AS case_value
	       ,SUM(stock_gsv)                AS gsv_value
	       ,SUM(sellout_next_28days_case) AS case_value_2
	       ,SUM(sellout_next_28days_gsv)  AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' DOH Latest'
	         ,fiscal_quarter
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY DOH'                      AS data_label
	       ,'Month'                       AS sub_year_label
	       ,'Inventory'                   AS theme_level
	       ,fiscal_year || ' DOH Last'    AS year_level
	       ,fiscal_month_show             AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(stock_case)               AS case_value
	       ,SUM(stock_gsv)                AS gsv_value
	       ,SUM(sellout_next_28days_case) AS case_value_2
	       ,SUM(sellout_next_28days_gsv)  AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' DOH Last'
	         ,fiscal_month_show
	         ,business_area_name
	         ,sales_district_name
	UNION ALL
	SELECT  'CY DOH'                      AS data_label
	       ,'Quarter'                     AS sub_year_label
	       ,'Inventory'                   AS theme_level
	       ,fiscal_year || ' DOH Last'    AS year_level
	       ,fiscal_quarter                AS sub_year_level
	       ,business_area_name
	       ,sales_district_name
	       ,SUM(stock_case)               AS case_value
	       ,SUM(stock_gsv)                AS gsv_value
	       ,SUM(sellout_next_28days_case) AS case_value_2
	       ,SUM(sellout_next_28days_gsv)  AS gsv_value_2
	FROM tb_sales_overview_monthly_flat_qbi
	WHERE mt <> ''
	AND fiscal_year = (
	SELECT  currenct_fiscal_year
	FROM cte_current_fiscal_year)
	GROUP BY  fiscal_year || ' DOH Last'
	         ,fiscal_quarter
	         ,business_area_name
	         ,sales_district_name
), cte_res AS
(
	SELECT  *
	FROM cte_sellout
	UNION ALL
	SELECT  *
	FROM cte_sellin
	UNION ALL
	SELECT  *
	FROM cte_inventory
)
SELECT  *
FROM cte_res