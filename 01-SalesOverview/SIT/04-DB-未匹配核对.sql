select date_range_type, fiscal_month,business_area_name, sum(cases)
from vw_sellin_coverpage_monthly_flat_qbi
where fiscal_year = 2025 and business_area_name in ('BD', '未匹配')
and fiscal_month <= 10 and date_range_type = 'YTD'
group by date_range_type, fiscal_month,business_area_name
order by fiscal_month