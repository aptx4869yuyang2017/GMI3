WITH cte_fact AS
(
	SELECT  cast(to_date(report_date,'yyyymmdd')                                                                AS date) report_date
	       ,business_area_name
	       ,sales_district_name
	       ,customer_group_2_name
	       ,customer_group_5_name
	       ,product_brand_name
	       ,product_category_name
	       ,customer_type
	       ,customer_name
	       ,CASE WHEN stat_weight <> '未匹配' THEN concat(stat_weight,stat_weight_unit_name)  ELSE stat_weight END AS stat_weight
	       ,product_flavour                                                                                     AS product_flavour
	       ,pieces
	       ,cases
	       ,gross_sales_incl_vat                                                                                AS gross_sales
	       ,gsv_mdm
	       ,pieces_ly
	       ,cases_ly
	       ,gross_sales_incl_vat_ly                                                                             AS gross_sales_ly
	       ,gsv_mdm_ly
	       ,pieces_lly
	       ,cases_lly
	       ,gross_sales_incl_vat_lly                                                                            AS gross_sales_lly
	       ,gsv_mdm_lly
	       ,pieces_target
	       ,gsv_target_incl_vat                                                                                 AS gsv_target
	       ,date_key
	       ,date_key_ly
	       ,date_key_lly
	       ,calday                                                                                              AS dt
	       ,calday_ly                                                                                           AS dt_ly
	       ,calday_lly                                                                                          AS dt_lly
	       ,week_day
	       ,week_day_ly
	       ,week_day_lly
	       ,holiday
	       ,CASE WHEN holiday_flag = 10 THEN 5
	             WHEN holiday_flag = 11 THEN 6
	             WHEN holiday_flag = 12 THEN 7
	             WHEN holiday_flag = 5 THEN 10
	             WHEN holiday_flag = 6 THEN 11
	             WHEN holiday_flag = 7 THEN 12  ELSE holiday_flag END                                           AS holiday_flag
	       ,holiday_begin
	       ,holiday_ly
	       ,CASE WHEN holiday_ly_flag = 10 THEN 5
	             WHEN holiday_ly_flag = 11 THEN 6
	             WHEN holiday_ly_flag = 12 THEN 7
	             WHEN holiday_ly_flag = 5 THEN 10
	             WHEN holiday_ly_flag = 6 THEN 11
	             WHEN holiday_ly_flag = 7 THEN 12  ELSE holiday_ly_flag END                                     AS holiday_ly_flag
	       ,holiday_begin_ly
	       ,holiday_lly
	       ,CASE WHEN holiday_lly_flag = 10 THEN 5
	             WHEN holiday_lly_flag = 11 THEN 6
	             WHEN holiday_lly_flag = 12 THEN 7
	             WHEN holiday_lly_flag = 5 THEN 10
	             WHEN holiday_lly_flag = 6 THEN 11
	             WHEN holiday_lly_flag = 7 THEN 12  ELSE holiday_lly_flag END                                   AS holiday_lly_flag
	       ,holiday_begin_lly
	       ,cast(to_date(substring(created_dt,1,10),'yyyy-mm-dd') AS date)                                      AS created_dt
	       ,cast(date_add(to_date(substring(created_dt,1,10),'yyyy-mm-dd'),-1) AS date)                         AS create_dt_yesterday
	       ,cast(date_add(to_date(substring(created_dt,1,10),'yyyy-mm-dd'),-2) AS date)                         AS create_dt_day_before
	FROM tb_pos_sales_calendar_flat_qbi
	WHERE dt >= '20240101'
	AND product_brand_name IN ('湾仔码头' ， '哈根达斯')
	AND business_area_name IN ('零售')
	AND customer_name IN ('世纪联华', '华润万家', '农工商', '北京华联' , '大润发', '大统华', '天虹商场', '家家悦' , '山姆', '新华都', '易初莲花', '永辉' , '沃尔玛', '物美', '联华', '苏果', '麦德龙') 
) , cte_next_month AS
(
	SELECT  MAX(to_char(cast(add_months(date_add(to_date(substring(created_dt,1,10),'yyyy-mm-dd'),-2),1) AS date),'yyyyMM')) AS next_month
	FROM tb_pos_sales_calendar_flat_qbi
	WHERE dt >= '20240101' 
)
SELECT  *
FROM cte_fact
WHERE substring(date_key, 1, 6) < (
SELECT  next_month
FROM cte_next_month )