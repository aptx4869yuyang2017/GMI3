SELECT  t1.date_range_type                                                                                  AS union_type
       ,t1.fiscal_year
       ,t1.fiscal_month
       ,t1.level_0
       ,t1.level_1
       ,t1.level_2
       ,t1.data_type
       ,t1.product_brand_name
       ,t1.cases
       ,t1.gsv                                                                                              AS gsv_comp
       ,t1.case_ly
       ,t1.gsv_ly                                                                                           AS gsv_comp_ly
       ,CASE WHEN level_1 IN ('NKA','RKA','DT','Retail') THEN stock_case_latest
             WHEN level_1 IN ('餐饮') THEN stock_gsv_incl_promotion_latest END                                AS stock_doh
       ,CASE WHEN level_1 IN ('NKA','RKA','DT','Retail') THEN sellout_case_latest_nm/days_of_next_fiscal_month
             WHEN level_1 IN ('餐饮') THEN sellout_gsv_incl_promotion_latest_nm/days_of_next_fiscal_month END AS sellout_doh
       ,t1.le_case                                                                                          AS le_case_org
       ,t1.le_gsv * 1e3                                                                                     AS le_gsv_org
       ,t1.st_case                                                                                          AS st_case_org
       ,t1.st_gsv * 1e3                                                                                     AS st_gsv_org
       ,t1.case_total
       ,t1.gsv_total                                                                                        AS gsv_comp_total
       ,t1.fiscal_yp
       ,t1.fiscal_year_month
       ,t1.fiscal_month_conse
       ,t1.fiscal_quarter_conse
       ,t1.time_pasting
FROM vw_sales_overview_channel_anal_monthly_flat_qbi AS t1
WHERE t1.fiscal_year >= 2024
AND t1.product_brand_name IN ('哈根达斯', '湾仔码头')
AND t1.level_2 NOT IN ('达上')
AND level_2 <> '公司调整项'
AND not (level_1 <> '未匹配' AND level_2 = '未匹配')