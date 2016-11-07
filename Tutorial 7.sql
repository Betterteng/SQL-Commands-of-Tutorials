desc charter_fact;

select * from charter_fact;

-- 1. What is the total hours flown by each pilot?
select emp_num, sum(total_hours_flown) as "Total Hours"
from charter_fact
group by emp_num
order by "Total Hours";

-- 2. Display the total hours flown by each pilot in a descending order.
select emp_num, sum(total_hours_flown) as "Total Hours"
from charter_fact
group by emp_num
order by "Total Hours" desc;

-- 3. What is the total hours flown by each category of pilot license?
select pd.PIL_LICENSE, sum(total_hours_flown) as "Total Hours"
from charter_fact cf, pilot_dim pd
where cf.EMP_NUM = pd.emp_num
group by pd.PIL_LICENSE
order by "Total Hours";

-- 4. What is the total revenue generated by each pilot? Sort the results based on the Pilot ID
select emp_num, sum(REVNUE) as "Total Revenue"
from CHARTER_FACT
group by emp_num;

-- 5. What is the total fuel consumption of the aircrafts manufactured by each manufacturer?
select md.MOD_MANUFACTURER, sum(TOTAL_FUEL) as "Total Fuel"
from model_dim md, charter_fact cf
where cf.mod_code = md.mod_code
group by md.MOD_MANUFACTURER;

-- 6. What is the total revenue generated in each year?
select td.TIME_YEAR, sum(cf.REVNUE) as "Total Revenue"
from time_dim td, charter_fact cf
where cf.TIME_ID = td.TIME_ID
group by td.TIME_year;

-- 1. What is the total fuel used from Oct to Dec 1995 by commercial pilots 
-- and airplane model C-90A. Sort the results by the month. How many rows of records do you get?
select cf.time_id as "Peroid", pd.emp_num as "Pilot Num", 
pd.PIL_LICENSE as "Pilot Type", md.mod_code as "Model", sum(cf.TOTAL_FUEL) as "Total Fuel"
from pilot_dim pd, model_dim md, charter_fact cf
where pd.EMP_NUM = cf.EMP_NUM
and cf.MOD_CODE = md.MOD_CODE
and cf.time_id like '19951%'
and md.MOD_CODE = 'C-90A'
and pd.PIL_LICENSE = 'COM'
group by cf.time_id, pd.emp_num, pd.PIL_LICENSE, md.mod_code
order by cf.time_id;

-- 2. Using cube, what is the total fuel used from Oct to Dec 1995 by commercial
-- pilots and airplane model C-90A. Sort the results by the month. How many rows of records do you get?
select cf.time_id as "Peroid", pd.emp_num as "Pilot Num", 
md.mod_code as "Model", sum(cf.TOTAL_FUEL) as "Total Fuel"
from pilot_dim pd, model_dim md, charter_fact cf
where pd.EMP_NUM = cf.EMP_NUM
and cf.MOD_CODE = md.MOD_CODE
and cf.time_id like '19951%'
and md.MOD_CODE = 'C-90A'
and pd.PIL_LICENSE = 'COM'
group by cube (cf.time_id, pd.emp_num, md.mod_code)
order by cf.time_id;

-- 3. Redo question C.2 using Grouping. Notes that “1” and “0” in the TIME, PILOT,
-- and MODEL indicate that they are aggregate values and real values respectively.
select cf.time_id as "Peroid", pd.emp_num as "Pilot Num", 
md.mod_code as "Model", sum(cf.TOTAL_FUEL) as "Total Fuel",
grouping (cf.time_id) as "TIME",
grouping (pd.emp_num) as "PILOT",
grouping (md.mod_code) as "MODEL"
from pilot_dim pd, model_dim md, charter_fact cf
where pd.EMP_NUM = cf.EMP_NUM
and cf.MOD_CODE = md.MOD_CODE
and cf.time_id like '19951%'
and md.MOD_CODE = 'C-90A'
and pd.PIL_LICENSE = 'COM'
group by cube (cf.time_id, pd.emp_num, md.mod_code)
order by cf.time_id;

-- 4. As like question C.3 above, but instead of using “0” and “1”, 
-- it displays “All Periods”, “All Pilots” and “All Models” instead. (Hints: Use DECODE).
select decode(grouping (cf.time_id),1,'All Periods',cf.time_id) as "Peroid", 
       decode(grouping (pd.emp_num),1,'All Pilots',pd.emp_num) as "Pilot Num", 
       decode(grouping (md.mod_code),1,'All Models',md.mod_code) as "Model",
       sum(cf.TOTAL_FUEL) as "Total Fuel"
from pilot_dim pd, model_dim md, charter_fact cf
where pd.EMP_NUM = cf.EMP_NUM
and cf.MOD_CODE = md.MOD_CODE
and cf.time_id like '19951%'
and md.MOD_CODE = 'C-90A'
and pd.PIL_LICENSE = 'COM'
group by cube (cf.time_id, pd.emp_num, md.mod_code)
order by cf.time_id;

-- 5. Following the results in question C.4, since there is only one aircraft
-- model in the query results (e.g. C-90A), it seems that the “All Models” are 
-- redundant. Now, we want to remove them from the report, as there is no point
-- displaying “All Models” when there is only one model (Hints: Use Partial CUBE).
select decode(grouping (cf.time_id),1,'All Periods',cf.time_id) as "Peroid", 
       decode(grouping (pd.emp_num),1,'All Pilots',pd.emp_num) as "Pilot Num", 
       decode(grouping (md.mod_code),1,'All Models',md.mod_code) as "Model",
       sum(cf.TOTAL_FUEL) as "Total Fuel"
from pilot_dim pd, model_dim md, charter_fact cf
where pd.EMP_NUM = cf.EMP_NUM
and cf.MOD_CODE = md.MOD_CODE
and cf.time_id like '19951%'
and md.MOD_CODE = 'C-90A'
and pd.PIL_LICENSE = 'COM'
group by cube (cf.time_id, pd.emp_num), md.mod_code
order by cf.time_id;

-- 6. Using rollup with decode, what is the total fuel used from Oct to Dec
-- 1995 by commercial pilots and airplane model C-90A. Sort the results by 
-- the month. How many rows of records do you get?
select decode(grouping (cf.time_id),1,'All Periods',cf.time_id) as "Peroid", 
       decode(grouping (pd.emp_num),1,'All Pilots',pd.emp_num) as "Pilot Num", 
       decode(grouping (md.mod_code),1,'All Models',md.mod_code) as "Model",
       sum(cf.TOTAL_FUEL) as "Total Fuel"
from pilot_dim pd, model_dim md, charter_fact cf
where pd.EMP_NUM = cf.EMP_NUM
and cf.MOD_CODE = md.MOD_CODE
and cf.time_id like '19951%'
and md.MOD_CODE = 'C-90A'
and pd.PIL_LICENSE = 'COM'
group by rollup (cf.time_id, pd.emp_num, md.mod_code)
order by cf.time_id;

-- 8. Modify C.6 to use Partial Roll up (exclude “All Models” from the rollup).
select decode(grouping (cf.time_id),1,'All Periods',cf.time_id) as "Peroid", 
       decode(grouping (pd.emp_num),1,'All Pilots',pd.emp_num) as "Pilot Num", 
       decode(grouping (md.mod_code),1,'All Models',md.mod_code) as "Model",
       sum(cf.TOTAL_FUEL) as "Total Fuel"
from pilot_dim pd, model_dim md, charter_fact cf
where pd.EMP_NUM = cf.EMP_NUM
and cf.MOD_CODE = md.MOD_CODE
and cf.time_id like '19951%'
and md.MOD_CODE = 'C-90A'
and pd.PIL_LICENSE = 'COM'
group by rollup (cf.time_id, pd.emp_num), md.mod_code
order by cf.time_id;
