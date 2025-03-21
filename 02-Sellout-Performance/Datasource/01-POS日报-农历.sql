WITH t AS
(
	SELECT  report_date
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
	       ,holiday_show
	       ,holiday_show_sort
	       ,calday                                                                                              AS dt
	       ,calday_ly                                                                                           AS dt_ly
	       ,calday_lly                                                                                          AS dt_lly
	       ,date_key
	       ,date_key_ly
	       ,date_key_lly
	       ,holiday_year
	       ,holiday_year_ly
	       ,holiday_year_lly
	       ,holiday
	       ,holiday_flag
	       ,holiday_ly
	       ,holiday_ly_flag
	       ,holiday_lly
	       ,holiday_lly_flag
	       ,created_dt
	       ,cast(date_add(to_date(substring(created_dt,1,10),'yyyy-mm-dd'),-1) AS date)                         AS create_dt_yesterday
	       ,cast(date_add(to_date(substring(created_dt,1,10),'yyyy-mm-dd'),-2) AS date)                         AS create_dt_day_before
	       ,cast(date_key AS int)                                                                               AS dt_int
	FROM tb_pos_sales_lunar_flat_qbi
	WHERE dt > '20241201'
	AND holiday_show is not null
	AND holiday_year >= 2025
	AND product_brand_name IN ('湾仔码头')
	AND ( (business_area_name = '零售' AND customer_name IN ('世纪联华', '华润万家', '农工商', '北京华联' , '大润发', '大统华', '天虹商场', '家家悦' , '山姆', '新华都', '易初莲花', '永辉' , '沃尔玛', '物美', '联华', '苏果', '麦德龙')) or (business_area_name = '电商' AND customer_name = '盒马')) 
)
SELECT  *
FROM t