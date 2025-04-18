WITH cte_current_year_month AS
(
	SELECT  MAX(fiscal_month_consecutive) AS max_fiscal_month_conse
	FROM tb_gm_date_master_dim
	WHERE date_key < (
	SELECT  MAX(REPLACE(SUBSTRING(created_dt,1,10),'-','')) AS formatted_date
	FROM vw_sellin_demand_accuracy_flat_qbi)
), cte_fact AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,fiscal_year_show
	       ,fiscal_month_show
	       ,business_area_name
	       ,customer_group_3_name
	       ,customer_group_name
	       ,sales_district_name
	       ,customer_group_2_name
	       ,customer_group_5_name
	       ,product_code
	       ,product_name
	       ,product_brand_name
	       ,product_category_name
	       ,product_midcategory_name
	       ,product_name_abbr
	       ,is_npd
	       ,stat_weight
	       ,warehouse
	       ,product_series_name
	       ,version_dmd
	       ,cases_demand_m0
	       ,gsv_demand_m0 * 1e3                                                         AS gsv_demand_m0
	       ,cases_demand_m1
	       ,gsv_demand_m1 * 1e3                                                         AS gsv_demand_m1
	       ,cases_demand_m3
	       ,gsv_demand_m3 * 1e3                                                         AS gsv_demand_m3
	       ,nvl(cases_act,0)                                                            AS cases_act
	       ,nvl(gsv_act,0)                                                              AS gsv_act
	       ,cases_act_ly
	       ,gsv_act_ly
	       ,cast(to_date(substring(created_dt,1,10),'yyyy-mm-dd') AS date)              AS created_dt
	       ,cast(date_add(to_date(substring(created_dt,1,10),'yyyy-mm-dd'),-1) AS date) AS busi_dt
	FROM vw_sellin_demand_accuracy_flat_qbi
	WHERE mt <> '' 
), cte_dim_data_monthly AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,fiscal_yp
	       ,CONCAT(fiscal_year_show,' ',fiscal_month_show) AS fiscal_year_month
	       ,fiscal_month_consecutive                       AS fiscal_month_conse
	       ,fiscal_quarter_consecutive                     AS fiscal_quarter_conse
	FROM tb_gm_date_master_dim
	GROUP BY  fiscal_year
	         ,fiscal_month
	         ,fiscal_quarter
	         ,fiscal_yp
	         ,CONCAT(fiscal_year_show,' ',fiscal_month_show)
	         ,fiscal_month_consecutive
	         ,fiscal_quarter_consecutive
) , res AS
(
	SELECT  t1.*
	       ,t2.fiscal_quarter
	       ,t2.fiscal_yp
	       ,t2.fiscal_year_month
	       ,t2.fiscal_month_conse
	       ,t2.fiscal_quarter_conse
	FROM cte_fact t1
	LEFT JOIN cte_dim_data_monthly t2
	ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month
	WHERE product_brand_name IN ('湾仔码头', '哈根达斯')
	AND t2.fiscal_month_conse <= (
	SELECT  MAX(max_fiscal_month_conse)
	FROM cte_current_year_month)
)
SELECT  *
FROM res