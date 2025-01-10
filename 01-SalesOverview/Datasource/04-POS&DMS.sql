SELECT  data_source
       ,concat( 'F',substring(fiscal_year,3,2),' ',fiscal_month )    AS fiscal_year_month
       ,fiscal_date_of_end_month
       ,fiscal_year
       ,fiscal_quarter
       ,fiscal_month
       ,fiscal_week_of_month
       ,int( fiscal_year * 12 + INT(replace(fiscal_month,'P0','')) ) AS fiscal_month_conse
       ,int( fiscal_year * 4 + int(SUBSTRING(fiscal_quarter,-1)) )   AS fiscal_quarter_conse
       ,report_date
       ,holiday
       ,holiday_begin
       ,dist_code
       ,shop_code
       ,shop_name
       ,dist_name
       ,custom_name
       ,CASE WHEN custom_type = '餐饮' THEN '经销商'  ELSE custom_type END custom_type
       ,business_area_name
       ,sales_district_name
       ,customer_group_2_name
       ,customer_group_5_name
       ,geo_region
       ,province_name
       ,city_name
       ,chain_type_name
       ,chain_group_name
       ,shop_type_name
       ,shop_subtype_name
       ,product_brand_name
       ,active_custom_code
       ,b_product_code
       ,b_product_name
       ,b_product_category_name
       ,b_product_midcategory_name
       ,b_product_subcategory_name
       ,b_product_cate5_name
       ,b_product_strategy
       ,new_prod_flag
       ,b_stat_weight
       ,b_stat_weight_unit_name
       ,b_product_barcode
       ,b_product_series_name
       ,SUM(pieces)                                                  AS pieces
       ,SUM(cases)                                                   AS cases
       ,SUM(gross_sales)                                             AS gross_sales
       ,SUM(gsv_mdm)                                                 AS gsv_mdm
       ,SUM(pieces_ly)                                               AS pieces_ly
       ,SUM(cases_ly)                                                AS cases_ly
       ,SUM(gross_sales_ly)                                          AS gross_sales_ly
       ,SUM(gsv_mdm_ly)                                              AS gsv_mdm_ly
       ,dw_source_system
       ,dw_source_table
       ,dt
       ,客户名称
FROM
(
	SELECT  data_source
	       ,fiscal_date_of_end_month
	       ,fiscal_year
	       ,fiscal_quarter
	       ,fiscal_month
	       ,fiscal_week_of_month
	       ,report_date
	       ,holiday
	       ,holiday_begin
	       ,dist_code
	       ,shop_code
	       ,shop_name
	       ,dist_name
	       ,custom_name
	       ,custom_type
	       ,business_area_name
	       ,sales_district_name
	       ,customer_group_2_name
	       ,customer_group_5_name
	       ,geo_region
	       ,province_name
	       ,city_name
	       ,chain_type_name
	       ,chain_group_name
	       ,shop_type_name
	       ,shop_subtype_name
	       ,product_brand_name
	       ,active_custom_code
	       ,b_product_code
	       ,b_product_name
	       ,b_product_category_name
	       ,b_product_midcategory_name
	       ,b_product_subcategory_name
	       ,b_product_cate5_name
	       ,b_product_strategy
	       ,new_prod_flag
	       ,b_stat_weight
	       ,b_stat_weight_unit_name
	       ,b_product_barcode
	       ,b_product_series_name
	       ,SUM(pieces)      AS pieces
	       ,SUM(cases)       AS cases
	       ,SUM(gross_sales) AS gross_sales
	       ,SUM(gsv_mdm)     AS gsv_mdm
	       ,0                AS pieces_ly
	       ,0                AS cases_ly
	       ,0                AS gross_sales_ly
	       ,0                AS gsv_mdm_ly
	       ,dw_source_system
	       ,dw_source_table
	       ,dt
	       ,CASE WHEN data_source = 'DMS' THEN dist_name
	             WHEN data_source = 'POS' THEN custom_name END 客户名称
	FROM tb_pos_dms_sales_detail_fact_lake_quickbi
	WHERE dt <> ''
	AND fiscal_year >= year(cast(GETDATE() AS date)) -2
	--
	AND business_area_name = '餐饮'
	GROUP BY  data_source
	         ,fiscal_date_of_end_month
	         ,fiscal_year
	         ,fiscal_quarter
	         ,fiscal_month
	         ,fiscal_week_of_month
	         ,report_date
	         ,holiday
	         ,holiday_begin
	         ,dist_code
	         ,shop_code
	         ,shop_name
	         ,dist_name
	         ,custom_name
	         ,custom_type
	         ,business_area_name
	         ,sales_district_name
	         ,customer_group_2_name
	         ,customer_group_5_name
	         ,geo_region
	         ,province_name
	         ,city_name
	         ,chain_type_name
	         ,chain_group_name
	         ,shop_type_name
	         ,shop_subtype_name
	         ,product_brand_name
	         ,active_custom_code
	         ,b_product_code
	         ,b_product_name
	         ,b_product_category_name
	         ,b_product_midcategory_name
	         ,b_product_subcategory_name
	         ,b_product_cate5_name
	         ,b_product_strategy
	         ,new_prod_flag
	         ,b_stat_weight
	         ,b_stat_weight_unit_name
	         ,b_product_barcode
	         ,b_product_series_name
	         ,dw_source_system
	         ,dw_source_table
	         ,dt
	         ,CASE WHEN data_source = 'DMS' THEN dist_name
	             WHEN data_source = 'POS' THEN custom_name END
	UNION ALL
	SELECT  t1.data_source
	       ,cast(t2.fiscal_date_of_end_month AS STRING) AS fiscal_date_of_end_month
	       ,cast(t2.fiscal_year AS STRING)              AS fiscal_year
	       ,cast(t2.fiscal_quarter AS STRING)           AS fiscal_quarter
	       ,concat('P',SUBSTRING(t2.fiscal_yp,5,2))     AS fiscal_month
	       ,cast(t2.fiscal_week_of_month AS STRING)     AS fiscal_week_of_month
	       ,cast(t2.date_key AS STRING)                 AS report_date
	       ,t1.holiday
	       ,t1.holiday_begin
	       ,t1.dist_code
	       ,t1.shop_code
	       ,t1.shop_name
	       ,t1.dist_name
	       ,t1.custom_name
	       ,t1.custom_type
	       ,t1.business_area_name
	       ,t1.sales_district_name
	       ,t1.customer_group_2_name
	       ,t1.customer_group_5_name
	       ,t1.geo_region
	       ,t1.province_name
	       ,t1.city_name
	       ,t1.chain_type_name
	       ,t1.chain_group_name
	       ,t1.shop_type_name
	       ,t1.shop_subtype_name
	       ,t1.product_brand_name
	       ,t1.active_custom_code
	       ,b_product_code
	       ,b_product_name
	       ,b_product_category_name
	       ,b_product_midcategory_name
	       ,b_product_subcategory_name
	       ,b_product_cate5_name
	       ,b_product_strategy
	       ,new_prod_flag
	       ,b_stat_weight
	       ,b_stat_weight_unit_name
	       ,b_product_barcode
	       ,b_product_series_name
	       ,0                                           AS pieces
	       ,0                                           AS cases
	       ,0                                           AS gross_sales
	       ,0                                           AS gsv_mdm
	       ,t1.pieces                                   AS pieces_ly
	       ,t1.cases                                    AS cases_ly
	       ,t1.gross_sales                              AS gross_sales_ly
	       ,t1.gsv_mdm                                  AS gsv_mdm_ly
	       ,t1.dw_source_system
	       ,t1.dw_source_table
	       ,cast(t2.date_key AS STRING)                 AS dt
	       ,t1.客户名称
	FROM
	(
		SELECT  data_source
		       ,fiscal_date_of_end_month
		       ,fiscal_year
		       ,fiscal_quarter
		       ,fiscal_month
		       ,fiscal_week_of_month
		       ,report_date
		       ,holiday
		       ,holiday_begin
		       ,dist_code
		       ,shop_code
		       ,shop_name
		       ,dist_name
		       ,custom_name
		       ,custom_type
		       ,business_area_name
		       ,sales_district_name
		       ,customer_group_2_name
		       ,customer_group_5_name
		       ,geo_region
		       ,province_name
		       ,city_name
		       ,chain_type_name
		       ,chain_group_name
		       ,shop_type_name
		       ,shop_subtype_name
		       ,product_brand_name
		       ,active_custom_code
		       ,b_product_code
		       ,b_product_name
		       ,b_product_category_name
		       ,b_product_midcategory_name
		       ,b_product_subcategory_name
		       ,b_product_cate5_name
		       ,b_product_strategy
		       ,new_prod_flag
		       ,b_stat_weight
		       ,b_stat_weight_unit_name
		       ,b_product_barcode
		       ,b_product_series_name
		       ,dw_source_system
		       ,dw_source_table
		       ,dt
		       ,CASE WHEN data_source = 'DMS' THEN dist_name
		             WHEN data_source = 'POS' THEN custom_name END 客户名称
		       ,SUM(pieces)      AS pieces
		       ,SUM(cases)       AS cases
		       ,SUM(gross_sales) AS gross_sales
		       ,SUM(gsv_mdm)     AS gsv_mdm
		FROM tb_pos_dms_sales_detail_fact_lake_quickbi
		WHERE dt <> ''
		AND fiscal_year >= year(cast(GETDATE() AS date)) -2 --
		LIMIT 1
		-- AND business_area_name = '餐饮'
		GROUP BY  data_source
		         ,fiscal_date_of_end_month
		         ,fiscal_year
		         ,fiscal_quarter
		         ,fiscal_month
		         ,fiscal_week_of_month
		         ,report_date
		         ,holiday
		         ,holiday_begin
		         ,dist_code
		         ,shop_code
		         ,shop_name
		         ,dist_name
		         ,custom_name
		         ,custom_type
		         ,business_area_name
		         ,sales_district_name
		         ,customer_group_2_name
		         ,customer_group_5_name
		         ,geo_region
		         ,province_name
		         ,city_name
		         ,chain_type_name
		         ,chain_group_name
		         ,shop_type_name
		         ,shop_subtype_name
		         ,product_brand_name
		         ,active_custom_code
		         ,b_product_code
		         ,b_product_name
		         ,b_product_category_name
		         ,b_product_midcategory_name
		         ,b_product_subcategory_name
		         ,b_product_cate5_name
		         ,b_product_strategy
		         ,new_prod_flag
		         ,b_stat_weight
		         ,b_stat_weight_unit_name
		         ,b_product_barcode
		         ,b_product_series_name
		         ,dw_source_system
		         ,dw_source_table
		         ,dt
		         ,CASE WHEN data_source = 'DMS' THEN dist_name
		             WHEN data_source = 'POS' THEN custom_name END
	) t1
	JOIN vw_dim_gm_date_master t2 on
	(t1.report_date = t2.date_key_ly
	)
) pp
--
WHERE pp.fiscal_year = '2025'
GROUP BY  data_source
         ,fiscal_date_of_end_month
         ,fiscal_year
         ,fiscal_quarter
         ,fiscal_month
         ,fiscal_week_of_month
         ,report_date
         ,holiday
         ,holiday_begin
         ,dist_code
         ,shop_code
         ,shop_name
         ,dist_name
         ,custom_name
         ,CASE WHEN custom_type = '餐饮' THEN '经销商'  ELSE custom_type END
         ,business_area_name
         ,sales_district_name
         ,customer_group_2_name
         ,customer_group_5_name
         ,geo_region
         ,province_name
         ,city_name
         ,chain_type_name
         ,chain_group_name
         ,shop_type_name
         ,shop_subtype_name
         ,product_brand_name
         ,active_custom_code
         ,b_product_code
         ,b_product_name
         ,b_product_category_name
         ,b_product_midcategory_name
         ,b_product_subcategory_name
         ,b_product_cate5_name
         ,b_product_strategy
         ,new_prod_flag
         ,b_stat_weight
         ,b_stat_weight_unit_name
         ,b_product_barcode
         ,b_product_series_name
         ,dw_source_system
         ,dw_source_table
         ,dt
         ,客户名称