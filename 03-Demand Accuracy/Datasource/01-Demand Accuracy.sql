WITH cte_fact AS
(
	SELECT  fiscal_year
	       ,fiscal_month
	       ,fiscal_year_show
	       ,fiscal_month_show
	       ,business_area_name
	       ,customer_group_4_name
	       ,customer_group_3_name
	       ,customer_group_name
	       ,sales_district_name
	       ,customer_group_2_name
	       ,customer_group_5_name
	       ,product_code
	       ,product_name
	       ,product_brand_name
	       ,product_category_name
	       ,warehouse
	       ,cases_demand_M0
	       ,gsv_demand_M0
	       ,cases_demand_M1
	       ,gsv_demand_M1
	       ,cases_demand_M3
	       ,gsv_demand_M3
	       ,cases_act
	       ,gsv_act
	       ,cast(to_date(substring(created_dt,1,10),'yyyy-mm-dd') AS date) AS created_dt
	FROM tb_sellin_demand_accuracy_flat_qbi
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
)
SELECT  t1.fiscal_year
       ,t1.fiscal_month
       ,t1.fiscal_year_show
       ,t1.fiscal_month_show
       ,t1.business_area_name
       ,t1.customer_group_4_name
       ,t1.customer_group_3_name
       ,t1.customer_group_name
       ,t1.sales_district_name
       ,t1.customer_group_2_name
       ,t1.customer_group_5_name
       ,t1.product_code
       ,t1.product_name
       ,t1.product_brand_name
       ,t1.product_category_name
       ,t1.warehouse
       ,t1.cases_demand_M0
       ,t1.gsv_demand_M0
       ,t1.cases_demand_M1
       ,t1.gsv_demand_M1
       ,t1.cases_demand_M3
       ,t1.gsv_demand_M3
       ,t1.cases_act
       ,t1.gsv_act
       ,t1.created_dt
       ,t2.fiscal_quarter
       ,t2.fiscal_yp
       ,t2.fiscal_year_month
       ,t2.fiscal_month_conse
       ,t2.fiscal_quarter_conse
FROM cte_fact t1
LEFT JOIN cte_dim_data_monthly t2
ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month