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
	       ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2)) AS fiscal_year_month
	       ,fiscal_month_consecutive                                         AS fiscal_month_conse
	       ,fiscal_quarter_consecutive                                       AS fiscal_quarter_conse
	       ,MAX(end_date_of_fiscal_month)                                    AS mtd_end
	       ,MAX(end_date_of_fiscal_quarter)                                  AS qtd_end
	       ,MAX(end_date_of_fiscal_year)                                     AS ytd_end
	FROM tb_gm_date_master_dim
	GROUP BY  fiscal_year
	         ,fiscal_month
	         ,fiscal_quarter
	         ,fiscal_yp
	         ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2))
	         ,fiscal_month_consecutive
	         ,fiscal_quarter_consecutive
)
SELECT  t1.*
       ,t2.fiscal_quart
       ,t2.fiscal_yp
       ,t2.fiscal_year_month
       ,t2.fiscal_month_conse
       ,t2.fiscal_quarter_conse
       ,t2.mtd_end
       ,t2.qtd_end
       ,t2.ytd_end
FROM cte_fact t1
LEFT JOIN cte_dim_data_monthly t2
ON t1.fiscal_year = t2.fiscal_year AND t1.fiscal_month = t2.fiscal_month