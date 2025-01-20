SELECT  cast(to_date(report_date,'yyyymmdd')                           AS date) report_date
       ,business_area_name
       ,sales_district_name
       ,product_brand_name
       ,product_category_name
       ,customer_type
       ,customer_name
       ,pieces
       ,cases
       ,gross_sales
       ,gsv_mdm
       ,pieces_ly
       ,cases_ly
       ,gross_sales_ly
       ,gsv_mdm_ly
       ,pieces_lly
       ,cases_lly
       ,gross_sales_lly
       ,gsv_mdm_lly
       ,pieces_target
       ,gsv_target
       ,date_key
       ,date_key_ly
       ,date_key_lly
       ,dt
       ,dt_ly
       ,dt_lly
       ,week_day
       ,week_day_ly
       ,week_day_lly
       ,holiday
       ,holiday_flag
       ,holiday_begin
       ,holiday_ly
       ,holiday_ly_flag
       ,holiday_begin_ly
       ,holiday_lly
       ,holiday_lly_flag
       ,holiday_begin_lly
       ,cast(to_date(substring(created_dt,1,10),'yyyy-mm-dd') AS date) AS created_dt
FROM tb_pos_holiday_sales_detail_fact
WHERE product_brand_name IN ('湾仔码头' )
AND business_area_name IN ('零售')
AND customer_type in('NKA', 'RKA')
AND sales_district_name <> '未匹配'
AND customer_name IN ('华润万家', '农工商', '北京华联' , '大润发', '大统华', '天虹商场', '家家悦' , '山姆', '新华都', '易初莲花', '永辉' , '沃尔玛', '物美', '联华', '苏果', '麦德龙')
AND year(dt) >= 2024