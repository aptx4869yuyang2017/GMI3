WITH dim_date AS
(
	SELECT  date_key
	       ,cast(end_date_of_fiscal_month AS STRING)                         AS fiscal_date_of_end_month
	       ,cast(fiscal_year AS STRING)                                      AS fiscal_year
	       ,cast(fiscal_quarter AS STRING)                                   AS fiscal_quarter
	       ,concat('P',SUBSTRING(fiscal_yp,5,2))                             AS fiscal_month
	       ,cast(fiscal_week_of_month AS STRING)                             AS fiscal_week_of_month
	       ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2)) AS fiscal_year_month
	       ,fiscal_month_consecutive                                         AS fiscal_month_conse
	       ,fiscal_quarter_consecutive                                       AS fiscal_quarter_conse
	FROM tb_gm_date_master_dim
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
	       ,customer_group_3_name                  AS custom_type
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
	       ,product_code                           AS b_product_code
	       ,product_name                           AS b_product_name
	       ,product_category_name                  AS b_product_category_name
	       ,product_midcategory_name               AS b_product_midcategory_name
	       ,product_subcategory_name               AS b_product_subcategory_name
	       ,product_cate5_name                     AS b_product_cate5_name
	       ,product_strategy                       AS b_product_strategy
	       ,new_prod_flag
	       ,stat_weight                            AS b_stat_weight
	       ,stat_weight_unit_name                  AS b_stat_weight_unit_name
	       ,product_barcode                        AS b_product_barcode
	       ,product_series_name                    AS b_product_series_name
	       ,CASE WHEN data_source = 'DMS' THEN dist_name  ELSE custom_name END 客户名称
	       ,SUM(pieces)                            AS pieces
	       ,SUM(cases)                             AS cases
	       ,SUM(gross_sales)                       AS gross_sales
	       ,SUM(gsv_mdm)                           AS gsv_mdm
	       ,SUM(pieces_ly)                         AS pieces_ly
	       ,SUM(cases_ly)                          AS cases_ly
	       ,SUM(gross_sales_ly)                    AS gross_sales_ly
	       ,SUM(gsv_mdm_ly)                        AS gsv_mdm_ly
	       ,SUM(pieces_incl_promotion_ly)          AS pieces_incl_promotion_ly
	       ,SUM(cases_incl_promotion_ly)           AS cases_incl_promotion_ly
	       ,SUM(gross_sales_incl_promotion_ly)     AS gross_sales_incl_promotion_ly
	       ,SUM(gsv_mdm_incl_promotion_ly)         AS gsv_mdm_incl_promotion_ly
	       ,SUM(gross_sales_incl_vat_ly)           AS gross_sales_incl_vat_ly
	       ,SUM(gsv_mdm_incl_vat_ly)               AS gsv_mdm_incl_vat_ly
	       ,SUM(gross_sales_incl_promotion_vat_ly) AS gross_sales_incl_promotion_vat_ly
	       ,SUM(gsv_mdm_incl_promotion_vat_ly)     AS gsv_mdm_incl_promotion_vat_ly
	       ,SUM(le_case)                           AS le_case
	       ,SUM(le_gsv)                            AS le_gsv
	       ,SUM(le_case_ly)                        AS le_case_ly
	       ,SUM(le_gsv_ly)                         AS le_gsv_ly
	       ,dw_source_system
	       ,dw_source_table
	FROM tb_pos_dms_sales_detail_daily_flat_qbi
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
	         ,product_code
	         ,product_name
	         ,product_category_name
	         ,product_midcategory_name
	         ,product_subcategory_name
	         ,product_cate5_name
	         ,product_strategy
	         ,new_prod_flag
	         ,stat_weight
	         ,stat_weight_unit_name
	         ,product_barcode
	         ,product_series_name
	         ,CASE WHEN data_source = 'DMS' THEN dist_name  ELSE custom_name END
	         ,dw_source_system
	         ,dw_source_table
)
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
       ,CASE WHEN t1.dist_code = '368765' THEN '北京枯石'
             WHEN t1.dist_code = '416574' THEN '贝贝瓶'  ELSE t1.custom_name END custom_name
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
       ,CASE WHEN t1.dist_code = '368765' THEN '北京枯石'
             WHEN t1.dist_code = '416574' THEN '贝贝瓶'  ELSE t1.客户名称 END 客户名称 -- 临时修改名称
       ,t1.pieces
       ,t1.cases
       ,t1.gross_sales
       ,t1.gsv_mdm
       ,t1.pieces_ly
       ,t1.cases_ly
       ,t1.gross_sales_ly
       ,t1.gsv_mdm_ly
       ,t1.pieces_incl_promotion_ly
       ,t1.cases_incl_promotion_ly
       ,t1.gross_sales_incl_promotion_ly
       ,t1.gsv_mdm_incl_promotion_ly
       ,t1.gross_sales_incl_vat_ly
       ,t1.gsv_mdm_incl_vat_ly
       ,t1.gross_sales_incl_promotion_vat_ly
       ,t1.gsv_mdm_incl_promotion_vat_ly
       ,t1.le_case
       ,t1.le_gsv
       ,t1.le_case_ly
       ,t1.le_gsv_ly
       ,t3.b_price1
       ,t3.b_price2
       ,t3.b_price3
       ,t3.b_price4
       ,t3.b_price5
       ,t3.b_price6
       ,t3.b_price7
       ,t3.b_price8
       ,t3.b_piece_per_case
       ,t3.b_product_basic_unit_code
       ,t1.dw_source_system
       ,t1.dw_source_table
FROM fact t1
LEFT JOIN dim_date AS t2
ON t1.report_date = t2.date_key
LEFT JOIN vw_mdm_product_dim AS t3
ON t1.b_product_code = t3.b_product_code AND nvl(t1.product_brand_name, '') NOT IN ('维邦')