WITH dim_date AS
(
	SELECT  date_key -- , date_key_ly
	       ,cast(fiscal_date_of_end_month AS STRING)                         AS fiscal_date_of_end_month
	       ,cast(fiscal_year AS STRING)                                      AS fiscal_year
	       ,cast(fiscal_quarter AS STRING)                                   AS fiscal_quarter
	       ,concat('P',SUBSTRING(fiscal_yp,5,2))                             AS fiscal_month
	       ,cast(fiscal_week_of_month AS STRING)                             AS fiscal_week_of_month
	       ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2)) AS fiscal_year_month
	       ,int(fiscal_year * 12 + fiscal_month)                             AS fiscal_month_conse
	       ,int(fiscal_year * 4 + int(SUBSTRING(fiscal_quarter,-1)))         AS fiscal_quarter_conse
	       ,1                                                                AS join_key
	FROM vw_dim_gm_date_master
) , fact AS
(
	SELECT  data_source
	       ,report_date
	       ,holiday
	       ,holiday_begin
	       ,dist_code
	       ,shop_code
	       ,shop_name
	       ,dist_name
	       ,custom_name
	       ,customer_group_3_name as custom_type
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
	       ,CASE WHEN data_source = 'DMS' THEN dist_name
	             ELSE custom_name END 客户名称
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
	FROM tb_pos_dms_sales_detail_fact_lake_quickbi
	WHERE dt <> ''
	AND fiscal_year >= year(GETDATE()) -2
	GROUP BY  data_source
	         ,report_date
	         ,holiday
	         ,holiday_begin
	         ,dist_code
	         ,shop_code
	         ,shop_name
	         ,dist_name
	         ,custom_name
	         ,customer_group_3_name
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
	         ,CASE WHEN data_source = 'DMS' THEN dist_name
	             ELSE custom_name END
), fact_ly AS
(
	SELECT  t1.data_source
	       ,t2.date_key    AS report_date
	       ,null           AS holiday
	       ,null           AS holiday_begin
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
	       ,t1.b_product_code
	       ,t1.b_product_name
	       ,t1.b_product_category_name
	       ,t1.b_product_midcategory_name
	       ,t1.b_product_subcategory_name
	       ,t1.b_product_cate5_name
	       ,t1.b_product_strategy
	       ,t1.new_prod_flag
	       ,t1.b_stat_weight
	       ,t1.b_stat_weight_unit_name
	       ,t1.b_product_barcode
	       ,t1.b_product_series_name
	       ,t1.客户名称
	       ,0              AS pieces
	       ,0              AS cases
	       ,0              AS gross_sales
	       ,0              AS gsv_mdm
	       ,t1.pieces      AS pieces_ly
	       ,t1.cases       AS cases_ly
	       ,t1.gross_sales AS gross_sales_ly
	       ,t1.gsv_mdm     AS gsv_mdm_ly
	       ,t1.dw_source_system
	       ,t1.dw_source_table
	FROM fact AS t1
	LEFT JOIN vw_dim_gm_date_master t2
	ON t1.report_date = t2.date_key_ly
    where t2.date_key is not null
), union_t AS
(
	SELECT  *
	FROM fact
	UNION ALL
	SELECT  *
	FROM fact_ly
), agg_fact AS
(
	SELECT  t1.data_source
	       ,t1.report_date
	       ,MAX(t1.holiday)        AS holiday
	       ,MAX(t1.holiday_begin)  AS holiday_begin
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
	       ,t1.b_product_code
	       ,t1.b_product_name
	       ,t1.b_product_category_name
	       ,t1.b_product_midcategory_name
	       ,t1.b_product_subcategory_name
	       ,t1.b_product_cate5_name
	       ,t1.b_product_strategy
	       ,t1.new_prod_flag
	       ,t1.b_stat_weight
	       ,t1.b_stat_weight_unit_name
	       ,t1.b_product_barcode
	       ,t1.b_product_series_name
	       ,t1.客户名称
	       ,SUM(t1.pieces)         AS pieces
	       ,SUM(t1.cases)          AS cases
	       ,SUM(t1.gross_sales)    AS gross_sales
	       ,SUM(t1.gsv_mdm)        AS gsv_mdm
	       ,SUM(t1.pieces_ly)      AS pieces_ly
	       ,SUM(t1.cases_ly)       AS cases_ly
	       ,SUM(t1.gross_sales_ly) AS gross_sales_ly
	       ,SUM(t1.gsv_mdm_ly)     AS gsv_mdm_ly
	       ,t1.dw_source_system
	       ,t1.dw_source_table
	FROM union_t AS t1
	GROUP BY  t1.data_source
	         ,t1.report_date
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
	         ,t1.b_product_code
	         ,t1.b_product_name
	         ,t1.b_product_category_name
	         ,t1.b_product_midcategory_name
	         ,t1.b_product_subcategory_name
	         ,t1.b_product_cate5_name
	         ,t1.b_product_strategy
	         ,t1.new_prod_flag
	         ,t1.b_stat_weight
	         ,t1.b_stat_weight_unit_name
	         ,t1.b_product_barcode
	         ,t1.b_product_series_name
	         ,t1.客户名称
	         ,t1.dw_source_system
	         ,t1.dw_source_table
) , res AS
(
	SELECT  t1.data_source
	       ,t1.report_date
	       ,t2.fiscal_date_of_end_month
	       ,t2.fiscal_year
	       ,t2.fiscal_quarter
	       ,t2.fiscal_month
	       ,t2.fiscal_week_of_month
	       ,t2.fiscal_year_month
	       ,t2.fiscal_month_conse
	       ,t2.fiscal_quarter_conse
	       ,t1.holiday
	       ,t1.holiday_begin
	       ,t1.dist_code
	       ,t1.shop_code
	       ,t1.shop_name
	       ,t1.dist_name
	       ,case when t1.dist_code ='368765' then '北京枯石'
                 when t1.dist_code ='416574' then '贝贝瓶'
                 else t1.custom_name end  custom_name
            
	    --   ,case when t1.business_area_name='餐饮' then '经销商' else t1.custom_type end custom_type
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
	       ,t1.b_product_code
	       ,t1.b_product_name
	       ,t1.b_product_category_name
	       ,t1.b_product_midcategory_name
	       ,t1.b_product_subcategory_name
	       ,t1.b_product_cate5_name
	       ,t1.b_product_strategy
	       ,t1.new_prod_flag
	       ,t1.b_stat_weight
	       ,t1.b_stat_weight_unit_name
	       ,t1.b_product_barcode
	       ,t1.b_product_series_name
	       ,case when t1.dist_code ='368765' then '北京枯石'
                 when t1.dist_code ='416574' then '贝贝瓶'
                 else t1.客户名称 end 客户名称    -- 临时修改名称
	       ,t1.pieces
	       ,t1.cases
	       ,t1.gross_sales
	       ,t1.gsv_mdm
	       ,t1.pieces_ly
	       ,t1.cases_ly
	       ,t1.gross_sales_ly
	       ,t1.gsv_mdm_ly
	       ,t3.b_price1
	       ,t3.b_price2
	       ,t3.b_price3
	       ,t3.b_price4
	       ,t3.b_price5
	       ,t3.b_price6
	       ,t3.b_price7
	       ,t3.b_price8
           , t3.b_piece_per_case
           , t3.b_product_basic_unit_code
	       ,t1.dw_source_system
	       ,t1.dw_source_table
	FROM agg_fact t1
	LEFT JOIN dim_date AS t2
	ON t1.report_date = t2.date_key
	LEFT JOIN vw_mdm_product_dim AS t3
	ON t1.b_product_code = t3.b_product_code
    AND nvl(t1.product_brand_name,'') NOT IN ('维邦')
)

select * from res