-- 临时表说明
-- fact1: tb_billing_coverpage_fact_test 在 日期 + 展示粒度上聚合
-- dim_date: 日期维度
-- b_t/brand_t: business_area_name / product_brand_name 所有数据为了补数据用
-- fact2: 为了计算占比，补齐 business_area_name/product_brand_name 数据 主要是 湾仔没有 shop
WITH fact1 AS
(
	SELECT  1                                    AS join_key
	       ,calendar_date
	       ,business_area_name
	       ,product_brand_name
	       ,SUM(billing_qty)                     AS billing_qty
	       ,SUM(list_price_revenue_excl_r100)    AS list_price_revenue_excl_r100
	       ,SUM(billing_qty_ly)                  AS billing_qty_ly
	       ,SUM(list_price_revenue_excl_r100_ly) AS list_price_revenue_excl_r100_ly
	       ,SUM(le_case)                         AS le_case
	       ,SUM(le_gsv)                          AS le_gsv
	       ,SUM(sp_case)                         AS sp_case
	       ,SUM(sp_gsv)                          AS sp_gsv
	FROM tb_billing_coverpage_fact_test
	GROUP BY  calendar_date
	         ,business_area_name
	         ,product_brand_name
), dim_date AS
(
	SELECT  date_key -- , date_key_ly
	       ,week_day -- , lunar_date
	       ,fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,fiscal_yp
	       ,fiscal_day_of_month
	       ,fiscal_week_of_month
	       ,fiscal_day_of_year
	       ,fiscal_week_of_year
	       ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2))                                                                           AS fiscal_year_month
	       ,int(fiscal_year * 12 + fiscal_month)                                                                                                       AS fiscal_month_conse
	       ,int(fiscal_year * 4 + int(SUBSTRING(fiscal_quarter,-1)))                                                                                   AS fiscal_quarter_conse
	       ,round(time_pasting_rate_of_month,4)                                                                                                        AS mtd_time_pasting
	       ,round(time_pasting_rate_of_quarter,4)                                                                                                      AS qtd_time_pasting
	       ,round(fiscal_day_of_year / (DATEDIFF(TO_DATE(date_key_end_for_target_mtd,'yyyymmdd'),TO_DATE(date_key_start_ytd,'yyyymmdd'),'day') + 1),4) AS ytd_time_pasting
	       ,1                                                                                                                                          AS join_key
	FROM vw_dim_gm_date_master
), b_t AS
(
	SELECT  1 AS join_key
	       ,business_area_name
	FROM fact1
	GROUP BY  business_area_name
), brand_t AS
(
	SELECT  1 AS join_key
	       ,product_brand_name
	FROM fact1
	GROUP BY  product_brand_name
), fact2 AS
(
	SELECT  join_key
	       ,calendar_date
	       ,business_area_name
	       ,product_brand_name
	       ,SUM(billing_qty)                     AS billing_qty
	       ,SUM(list_price_revenue_excl_r100)    AS list_price_revenue_excl_r100
	       ,SUM(billing_qty_ly)                  AS billing_qty_ly
	       ,SUM(list_price_revenue_excl_r100_ly) AS list_price_revenue_excl_r100_ly
	       ,SUM(le_case)                         AS le_case
	       ,SUM(le_gsv)                          AS le_gsv
	       ,SUM(sp_case)                         AS sp_case
	       ,SUM(sp_gsv)                          AS sp_gsv
	FROM
	(
		SELECT  *
		FROM fact1
		UNION ALL
		SELECT  1           AS join_key
		       ,t3.date_key AS calendar_date
		       ,t1.business_area_name
		       ,t2.product_brand_name
		       ,0           AS billing_qty
		       ,0           AS list_price_revenue_excl_r100
		       ,0           AS billing_qty_ly
		       ,0           AS list_price_revenue_excl_r100_ly
		       ,0           AS le_case
		       ,0           AS le_gsv
		       ,0           AS sp_case
		       ,0           AS sp_gsv
		FROM b_t AS t1
		LEFT JOIN brand_t AS t2
		ON t1.join_key = t2.join_key
		LEFT JOIN dim_date t3
		ON t3.join_key = t1.join_key
	)
	GROUP BY  join_key
	         ,calendar_date
	         ,business_area_name
	         ,product_brand_name
)
SELECT  t1.calendar_date                                                                                    AS dt
       ,t2.*
       ,t1.business_area_name                                                                               AS business_area_name
       ,t1.product_brand_name
       ,t1.billing_qty                                                                                      AS cases
       ,nvl(t1.list_price_revenue_excl_r100,0)                                                              AS gsv_comp
       ,CASE WHEN t1.calendar_date < TO_CHAR(GETDATE(),'yyyymmdd') THEN billing_qty_ly END                  AS cases_ly
       ,CASE WHEN t1.calendar_date < TO_CHAR(GETDATE(),'yyyymmdd') THEN list_price_revenue_excl_r100_ly END AS gsv_comp_ly
       ,le_case
       ,le_gsv * 1e3                                                                                        AS le_gsv
       ,sp_case
       ,sp_gsv * 1e3                                                                                        AS sp_gsv
       ,le_case                                                                                             AS st_case
       ,le_gsv * 1e3                                                                                        AS st_gsv
       ,SUM(t1.billing_qty) OVER (PARTITION BY t1.product_brand_name,t1.calendar_date)                      AS case_total
       ,SUM(t1.list_price_revenue_excl_r100) OVER (PARTITION BY t1.product_brand_name,t1.calendar_date )    AS gsv_total
FROM fact2 AS t1
LEFT JOIN dim_date AS t2
ON t1.calendar_date = t2.date_key
WHERE business_area_name IN ('餐饮', '零售', '电商', 'Shop')
AND fiscal_year >= 2024