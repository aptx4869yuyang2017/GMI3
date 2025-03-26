
-- overview kpi
select date_range_type, fiscal_month,business_area_name, sum(cases)
from vw_sellin_coverpage_monthly_flat_qbi
where fiscal_year = 2025 and business_area_name in ('BD', '未匹配')
and fiscal_month <= 10 and date_range_type = 'YTD'
group by date_range_type, fiscal_month,business_area_name
order by fiscal_month



-- 渠道分析
select product_brand_name, date_range_type, fiscal_month,level_0, level_1, sum(cases) 
from vw_sales_overview_channel_anal_monthly_flat_qbi
where fiscal_year = 2025 and product_brand_name in ('哈根达斯', '湾仔码头') and date_range_type = 'YTD'
and  level_1 in ('BD', '未匹配') and fiscal_month = 10
group by date_range_type, fiscal_month,level_0, level_1, product_brand_name
order by product_brand_name, fiscal_month



-- 进销存总览