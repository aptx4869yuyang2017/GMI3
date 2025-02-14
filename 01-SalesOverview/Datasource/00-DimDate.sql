-- SELECT *
FROM tb_gm_date_master_dim
WITH dim_date AS
(
	SELECT  date_key
	       ,date_key_ly
	       ,week_day
	       ,lunar_date
	       ,fiscal_year
	       ,fiscal_month
	       ,fiscal_quarter
	       ,fiscal_yp
	       ,fiscal_day_of_month
	       ,LPAD(fiscal_day_of_month,2,'0')                                                                                               AS fiscal_day
	       ,fiscal_week_of_month
	       ,fiscal_day_of_year
	       ,fiscal_week_of_year
	       ,CONCAT('F',SUBSTR(fiscal_year,-2),' P',SUBSTRING(fiscal_yp,5,2))                                                              AS fiscal_year_month
	       ,int(fiscal_year * 12 + fiscal_month)                                                                                          AS fiscal_month_conse
	       ,int(fiscal_year * 4 + int(SUBSTRING(fiscal_quarter,-1)))                                                                      AS fiscal_quarter_conse
	       ,round(time_pasting_rate_of_month,4)                                                                                           AS mtd_time_pasting
	       ,round(time_pasting_rate_of_quarter,4)                                                                                         AS qtd_time_pasting
	       ,round(time_pasting_rate_of_year,4)                                                                                            AS ytd_time_pasting
	       ,CONCAT(CAST(SUBSTRING(start_date_of_fiscal_month,5,2) AS int),'/',CAST(SUBSTRING(start_date_of_fiscal_month,7,2) AS int))     AS mtd_begin
	       ,CONCAT(CAST(SUBSTRING(end_date_of_fiscal_month,5,2) AS int),'/',CAST(SUBSTRING(end_date_of_fiscal_month,7,2) AS int))         AS mtd_end
	       ,CONCAT(CAST(SUBSTRING(start_date_of_fiscal_quarter,5,2) AS int),'/',CAST(SUBSTRING(start_date_of_fiscal_quarter,7,2) AS int)) AS qtd_begin
	       ,CONCAT(CAST(SUBSTRING(end_date_of_fiscal_quarter,5,2) AS int),'/',CAST(SUBSTRING(end_date_of_fiscal_quarter,7,2) AS int))     AS qtd_end
	       ,CONCAT(CAST(SUBSTRING(start_date_of_fiscal_year,5,2) AS int),'/',CAST(SUBSTRING(start_date_of_fiscal_year,7,2) AS int))       AS ytd_begin
	       ,CONCAT(CAST(SUBSTRING(end_date_of_fiscal_year,5,2) AS int),'/',CAST(SUBSTRING(end_date_of_fiscal_quarter,7,2) AS int))        AS ytd_end
	       ,round(fiscal_days_of_month / 7,0)                                                                                             AS mtd_week_count
	       ,round(fiscal_days_of_quarter / 7,0)                                                                                           AS qtd_week_count
	       ,round((DATEDIFF(TO_DATE(end_date_of_fiscal_year,'yyyymmdd'),TO_DATE(start_date_of_fiscal_year,'yyyymmdd'),'day') + 1) / 7,0)  AS ytd_week_count
	FROM tb_gm_date_master_dim
)
SELECT  *
FROM dim_date
WHERE date_key < TO_CHAR(GETDATE(), 'yyyymmdd')
AND fiscal_year >= 2024