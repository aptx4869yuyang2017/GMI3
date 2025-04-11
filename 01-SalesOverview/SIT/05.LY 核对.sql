SELECT  t1.date_range_type                                                          AS xtd_type
       ,t1.fiscal_year
       ,t1.fiscal_month
       ,t1.business_area_name
       ,t1.product_brand_name

       ,sum(t1.gsv_ly) as gsv_ly

       ,sum(t1.gsv)/sum(t1.gsv_ly)-1 as gsv_pct
      
FROM vw_sellin_coverpage_monthly_flat_qbi t1
WHERE t1.fiscal_year = 2025 and fiscal_month = 11
AND t1.product_brand_name IN ('哈根达斯', '湾仔码头') and date_range_type = 'MTD'
group by t1.date_range_type                                               
       ,t1.fiscal_year
       ,t1.fiscal_month
       ,t1.business_area_name
       ,t1.product_brand_name





SELECT                                                       
       t1.fiscal_year
       ,t1.fiscal_month
       ,t1.business_area_name
       ,t1.product_brand_name
       ,sum(t1.list_price_revenue_excl_r100) as gsv
       ,sum(t1.list_price_revenue_excl_r100_ly) as gsv_ly
         ,round((sum(t1.list_price_revenue_excl_r100)/sum(t1.list_price_revenue_excl_r100_ly)-1)*100) as gsv_pct
FROM tb_billing_coverpage_fact t1
WHERE t1.fiscal_year = 2025 and fiscal_month = 11
AND t1.product_brand_name IN ('哈根达斯', '湾仔码头') 
-- and date_range_type = 'MTD'
group by                                            
       t1.fiscal_year
       ,t1.fiscal_month
       ,t1.business_area_name
       ,t1.product_brand_name