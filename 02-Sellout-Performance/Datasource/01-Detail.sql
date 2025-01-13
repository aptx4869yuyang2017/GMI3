WITH holiday AS
(
	SELECT  report_date
	       ,cast(to_date(report_date,'yyyymmdd') AS date) AS dt
	       ,holiday
	       ,holiday_begin
	FROM vw_pos_holiday_flag
	WHERE report_date >= '2022/12/22'
	AND holiday IN ( '春节', '元宵', '元旦', '冬至') 
), dim_date AS
(
	SELECT  cast(to_date(date_key,'yyyymmdd') AS date)                    AS dt
	       ,dateadd(cast(to_date(date_key,'yyyymmdd') AS date),-1,'yyyy') AS dt_ly
	       ,dateadd(cast(to_date(date_key,'yyyymmdd') AS date),-2,'yyyy') AS dt_lly
	       ,date_key
	       ,week_day
	FROM vw_dim_gm_date_master
), dim_date_holiday AS
(
	SELECT  t1.date_key
	       ,t1.dt
	       ,t1.dt_ly
	       ,t1.dt_lly
	       ,t1.week_day
	       ,t2.week_day                                     AS week_day_ly
	       ,t3.week_day                                     AS week_day_lly
	       ,CASE WHEN h1.holiday is not null THEN h1.holiday
	             WHEN t1.week_day >= 5 THEN '休息日' END       AS holiday
	       ,CASE WHEN h1.holiday = '冬至' THEN 1
	             WHEN h1.holiday = '元旦' THEN 2
	             WHEN h1.holiday = '春节' THEN 3
	             WHEN h1.holiday = '元宵' THEN 4
	             WHEN t1.week_day >= 5 THEN t1.week_day END AS holiday_flag
	       ,h1.holiday_begin
	       ,CASE WHEN h2.holiday is not null THEN h2.holiday
	             WHEN t2.week_day >= 5 THEN '休息日' END       AS holiday_ly
	       ,CASE WHEN h2.holiday = '冬至' THEN 1
	             WHEN h2.holiday = '元旦' THEN 2
	             WHEN h2.holiday = '春节' THEN 3
	             WHEN h2.holiday = '元宵' THEN 4
	             WHEN t2.week_day >= 5 THEN t2.week_day END AS holiday_ly_flag
	       ,h2.holiday_begin holiday_begin_ly
	       ,CASE WHEN h3.holiday is not null THEN h3.holiday
	             WHEN t3.week_day >= 5 THEN '休息日' END       AS holiday_lly
	       ,CASE WHEN h3.holiday = '冬至' THEN 1
	             WHEN h3.holiday = '元旦' THEN 2
	             WHEN h3.holiday = '春节' THEN 3
	             WHEN h3.holiday = '元宵' THEN 4
	             WHEN t3.week_day >= 5 THEN t3.week_day END AS holiday_lly_flag
	       ,h3.holiday_begin                                AS holiday_begin_lly
	FROM dim_date t1
	LEFT JOIN dim_date AS t2
	ON t1.dt_ly = t2.dt
	LEFT JOIN dim_date AS t3
	ON t1.dt_lly = t3.dt
	LEFT JOIN holiday h1
	ON t1.dt = h1.dt
	LEFT JOIN holiday h2
	ON t1.dt_ly = h2.dt
	LEFT JOIN holiday h3
	ON t1.dt_lly = h3.dt
), fact AS
(
	SELECT  data_source
	       ,cast(to_date(report_date,'yyyymmdd') AS date) AS report_date
	       ,business_area_name
	       ,sales_district_name
	       ,product_brand_name
	       ,b_product_category_name
	       ,custom_type
	       ,CASE WHEN data_source = 'DMS' THEN dist_name
	             WHEN data_source = 'POS' THEN custom_name END customer_name
	       ,SUM(pieces)                                   AS pieces
	       ,SUM(cases)                                    AS cases
	       ,SUM(gross_sales)                              AS gross_sales
	       ,SUM(gsv_mdm)                                  AS gsv_mdm
	       ,0                                             AS pieces_ly
	       ,0                                             AS cases_ly
	       ,0                                             AS gross_sales_ly
	       ,0                                             AS gsv_mdm_ly
	       ,0                                             AS pieces_lly
	       ,0                                             AS cases_lly
	       ,0                                             AS gross_sales_lly
	       ,0                                             AS gsv_mdm_lly
	FROM tb_pos_dms_sales_detail_fact_lake_quickbi
	WHERE dt <> ''
	AND fiscal_year >= year(GETDATE()) -2
	GROUP BY  data_source
	         ,cast(to_date(report_date,'yyyymmdd') AS date)
	         ,business_area_name
	         ,sales_district_name
	         ,product_brand_name
	         ,b_product_category_name
	         ,custom_type
	         ,CASE WHEN data_source = 'DMS' THEN dist_name
	             WHEN data_source = 'POS' THEN custom_name END
), fact_ly AS
(
	SELECT  t1.data_source
	       ,t2.dt          AS report_date
	       ,t1.business_area_name
	       ,t1.sales_district_name
	       ,t1.product_brand_name
	       ,t1.b_product_category_name
	       ,t1.custom_type
	       ,t1.customer_name
	       ,0              AS pieces
	       ,0              AS cases
	       ,0              AS gross_sales
	       ,0              AS gsv_mdm
	       ,t1.pieces      AS pieces_ly
	       ,t1.cases       AS cases_ly
	       ,t1.gross_sales AS gross_sales_ly
	       ,t1.gsv_mdm     AS gsv_mdm_ly
	       ,0              AS pieces_lly
	       ,0              AS cases_lly
	       ,0              AS gross_sales_lly
	       ,0              AS gsv_mdm_lly
	FROM fact AS t1
	LEFT JOIN dim_date t2
	ON t1.report_date = t2.dt_ly
	WHERE t2.dt is not null 
) , fact_lly AS
(
	SELECT  t1.data_source
	       ,t2.dt          AS report_date
	       ,t1.business_area_name
	       ,t1.sales_district_name
	       ,t1.product_brand_name
	       ,t1.b_product_category_name
	       ,custom_type
	       ,t1.customer_name
	       ,0              AS pieces
	       ,0              AS cases
	       ,0              AS gross_sales
	       ,0              AS gsv_mdm
	       ,0              AS pieces_ly
	       ,0              AS cases_ly
	       ,0              AS gross_sales_ly
	       ,0              AS gsv_mdm_ly
	       ,t1.pieces      AS pieces_lly
	       ,t1.cases       AS cases_lly
	       ,t1.gross_sales AS gross_sales_lly
	       ,t1.gsv_mdm     AS gsv_mdm_lly
	FROM fact AS t1
	LEFT JOIN dim_date t2
	ON t1.report_date = t2.dt_lly
	WHERE t2.dt is not null 
), union_fact AS
(
	SELECT  *
	FROM fact
	UNION ALL
	SELECT  *
	FROM fact_ly
	UNION ALL
	SELECT  *
	FROM fact_lly
), fact_agg AS
(
	SELECT  t1.data_source
	       ,t1.report_date
	       ,t1.business_area_name
	       ,t1.sales_district_name
	       ,t1.product_brand_name
	       ,t1.b_product_category_name
	       ,t1.custom_type
	       ,t1.customer_name
	       ,SUM(pieces)          AS pieces
	       ,SUM(cases)           AS cases
	       ,SUM(gross_sales)     AS gross_sales
	       ,SUM(gsv_mdm)         AS gsv_mdm
	       ,SUM(pieces_ly)       AS pieces_ly
	       ,SUM(cases_ly)        AS cases_ly
	       ,SUM(gross_sales_ly)  AS gross_sales_ly
	       ,SUM(gsv_mdm_ly)      AS gsv_mdm_ly
	       ,SUM(pieces_lly)      AS pieces_lly
	       ,SUM(cases_lly)       AS cases_lly
	       ,SUM(gross_sales_lly) AS gross_sales_lly
	       ,SUM(gsv_mdm_lly)     AS gsv_mdm_lly
	FROM union_fact t1
	GROUP BY  t1.data_source
	         ,t1.report_date
	         ,t1.business_area_name
	         ,t1.sales_district_name
	         ,t1.product_brand_name
	         ,t1.b_product_category_name
	         ,t1.customer_name
	         ,t1.custom_type
)
SELECT  t1.*
       ,t2.*
FROM fact_agg t1
LEFT JOIN dim_date_holiday t2
ON t1.report_date = t2.dt
WHERE product_brand_name IN ('哈根达斯', '湾仔码头')