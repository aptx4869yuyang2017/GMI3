SELECT  report_date
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
       ,holiday_show
       ,holiday_show_sort
       ,calday                                                                      AS dt
       ,calday_ly                                                                   AS dt_ly
       ,calday_lly                                                                  AS dt_lly
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
       ,date_key
       ,date_key_ly
       ,date_key_lly
       ,cast(date_add(to_date(substring(created_dt,1,10),'yyyy-mm-dd'),-1) AS date) AS create_dt_yesterday
       ,cast(date_key AS int)                                                       AS dt_int
       ,hel
FROM tb_pos_sales_lunar_flat_qbi
WHERE dt <> ''
AND holiday_show is not null
AND holiday_year >= 2025
AND product_brand_name IN ('湾仔码头')
AND business_area_name IN ('零售')
AND customer_type in('NKA', 'RKA')
AND customer_name IN ('世纪联华', '华润万家', '农工商', '北京华联' , '大润发', '大统华', '天虹商场', '家家悦' , '山姆', '新华都', '易初莲花', '永辉' , '沃尔玛', '物美', '联华', '苏果', '麦德龙')