select sales_district_name
	       ,customer_group_2_name
	       ,customer_group_5_name from tb_pos_dms_sales_detail_fact_lake_quickbi
where business_area_name = '电商' and data_source = 'POS' and dt <> ''
group by sales_district_name
	       ,customer_group_2_name
	       ,customer_group_5_name