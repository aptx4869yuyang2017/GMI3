WITH dim_date AS
(
	SELECT  date_key
	       ,cast(end_date_of_fiscal_month AS STRING)       AS fiscal_date_of_end_month
	       ,cast(fiscal_year AS STRING)                    AS fiscal_year
	       ,cast(fiscal_quarter AS STRING)                 AS fiscal_quarter
	       ,concat(fiscal_month_show)                      AS fiscal_month
	       ,cast(fiscal_week_of_month AS STRING)           AS fiscal_week_of_month
	       ,CONCAT(fiscal_year_show,' ',fiscal_month_show) AS fiscal_year_month
	       ,fiscal_month_consecutive                       AS fiscal_month_conse
	       ,fiscal_quarter_consecutive                     AS fiscal_quarter_conse
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
		   ,customer_group_name
	       ,geo_region
	       ,province_name
	       ,city_name
	       ,chain_type_name
	       ,chain_group_name
	       ,shop_type_name
	       ,shop_subtype_name
	       ,product_brand_name
	       ,active_custom_code
	       ,product_category_name                  AS b_product_category_name
	       ,SUM(pieces)                            AS pieces
	       ,SUM(cases)                             AS cases
	       ,SUM(gross_sales)                       AS gross_sales
	       ,SUM(gsv_mdm)                           AS gsv_mdm
	       ,SUM(pieces_incl_promotion)             AS pieces_incl_promotion
	       ,SUM(cases_incl_promotion)              AS cases_incl_promotion
	       ,SUM(gross_sales_incl_promotion)        AS gross_sales_incl_promotion
	       ,SUM(gsv_mdm_incl_promotion)            AS gsv_mdm_incl_promotion
	       ,SUM(gross_sales_incl_vat)              AS gross_sales_incl_vat
	       ,SUM(gsv_mdm_incl_vat)                  AS gsv_mdm_incl_vat
	       ,SUM(gross_sales_incl_promotion_vat)    AS gross_sales_incl_promotion_vat
	       ,SUM(gsv_mdm_incl_promotion_vat)        AS gsv_mdm_incl_promotion_vat
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
	FROM tb_sellout_sales_detail_daily_flat_qbi
	WHERE dt >= '20230529' -- AND fiscal_year >= '2024'
	AND business_area_name = '餐饮'
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
			 ,customer_group_name
	         ,geo_region
	         ,province_name
	         ,city_name
	         ,chain_type_name
	         ,chain_group_name
	         ,shop_type_name
	         ,shop_subtype_name
	         ,product_brand_name
	         ,active_custom_code
	         ,product_category_name
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
       ,nvl(t1.customer_group_name,t1.custom_name) AS custom_name
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
       ,t1.b_product_category_name
       ,case when custom_type = '直营' THEN customer_group_name else t1.dist_name end AS 客户名称 
       ,t1.pieces
       ,t1.cases
       ,t1.gross_sales
       ,t1.gsv_mdm
       ,t1.pieces_incl_promotion
       ,t1.cases_incl_promotion
       ,t1.gross_sales_incl_promotion
       ,t1.gsv_mdm_incl_promotion
       ,t1.gross_sales_incl_vat
       ,t1.gsv_mdm_incl_vat
       ,t1.gross_sales_incl_promotion_vat
       ,t1.gsv_mdm_incl_promotion_vat
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
       ,t1.dw_source_system
       ,t1.dw_source_table
FROM fact t1
LEFT JOIN dim_date AS t2
ON t1.report_date = t2.date_key
WHERE t1.product_brand_name in ('哈根达斯', '湾仔码头')