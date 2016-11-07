select * from time_Dim;

-- 1. The rank function displays the rank of a record. 
-- Its usage is as follow. To find the rank of the records 
-- in the time table is as follow:
SELECT TIME_YEAR, TIME_MONTH,
       RANK() OVER (ORDER BY TIME_YEAR, TIME_MONTH) AS "Time Rank"
FROM dw.time;

-- 2. Try the query below and compare the result with A.1. 
-- Investigate the purpose of using ‘+0’ in order by time_month.
SELECT TIME_YEAR, TIME_MONTH,
       RANK() OVER (ORDER BY TIME_YEAR, TIME_MONTH+0) AS "Time Rank"
FROM dw.time;

-- 3. Display the row number of total charter hours used by each aircraft model
--in year 1996 (Hints: Use ROW_NUMBER() Over) The results should look like as follows.
select cf.MOD_CODE, cf.TIME_id, sum(cf.total_hours_flown),
       row_number() over (order by sum(cf.total_hours_flown)) as "Row Number"
from charter_fact cf
where cf.time_id like '1996%'
group by cf.MOD_CODE, cf.TIME_id;

-- 4. Display the ranking of total charter hours used by each aircraft model in 
-- year 1996(Hints: Use Dense_Rank() Over) The results should look like as follows.
select cf.MOD_CODE, cf.TIME_id, sum(cf.total_hours_flown),
       dense_rank() over (order by sum(cf.total_hours_flown)) as "Row Number"
from charter_fact cf
where cf.time_id like '1996%'
group by cf.MOD_CODE, cf.TIME_id;

-- 6. Display the ranking of total charter hours used by each aircraft model in year
-- 1996 (Hints: Use Rank() Over) The results should look like as follows.
select cf.MOD_CODE, cf.TIME_id, sum(cf.total_hours_flown),
       rank() over (order by sum(cf.total_hours_flown)) as "Row Number"
from charter_fact cf
where cf.time_id like '1996%'
group by cf.MOD_CODE, cf.TIME_id;

-- 8. Modify the ranking in question A.6 above, where ranking based on Model, 
-- so that the results will look like this:
select cf.MOD_CODE, cf.TIME_id, sum(cf.total_hours_flown),
       rank() over (order by cf.MOD_CODE) as "Row Number"
from charter_fact cf
where cf.time_id like '1996%'
group by cf.MOD_CODE, cf.TIME_id;

-- 9. Display the ranking of each airplane model based on the yearly total 
-- fuel-used and the ranking of yearly total fuel-used by each airplane model,
--and (Hints: use multiple partitioning ranking).
select td.time_year, cf.MOD_CODE, 
       sum(cf.total_fuel) as "Total Hours",
       rank() over (partition by td.time_year order by sum(cf.total_fuel) desc) as "Rank by year",
       rank() over (partition by cf.MOD_CODE order by sum(cf.total_fuel) desc) as "Rank by model"
from time_dim td, charter_fact cf
where td.time_id = cf.time_id
group by td.time_year, cf.MOD_CODE;

-- 10. Using the rank function (nested within a sub query, because rank cannot 
-- exist in a where clause) display the mod_code and mod_name of the two 
-- airplanes that have the largest total fuel used.
select * 
from (select cf.mod_code, md.mod_name,
             sum(cf.total_fuel) as "Total Fuel",
             dense_rank() over (order by sum(cf.total_fuel) desc) as Rank_By_Model
      from charter_fact cf, model_dim md
      where cf.mod_code = md.mod_code
      group by cf.mod_code, md.mod_name
     )
where Rank_By_Model in (1,2);

-- 11. Using the Percent_Rank() function (nested within a sub query), 
-- display the time periods which had revenue in the top 10% of the months.
select * 
from (select cf.time_id, 
             sum(cf.REVNUE) as Total_Revenue,
             ROUND(TO_CHAR(percent_rank() over (order by sum(cf.REVNUE) desc)),4) as Rank_By_Revenue
      from charter_fact cf
      group by cf.time_id
      )
where Rank_By_Revenue <= 0.1;

-- PART B

-- 1. Use the cumulative aggregate to show the following results. 
-- We only need to show 1995 revenues (Hints: Since we only display 1995 data,
-- there is no PARTITION).
select cf.time_id, 
       sum(cf.revnue) as Total_Revenue,
       TO_CHAR(SUM(SUM(cf.revnue)) OVER(ORDER BY cf.time_id ROWS UNBOUNDED PRECEDING), '9,999,999.99') AS Cummulative_Rev
from charter_fact cf
where cf.TIME_ID like '1995%'
group by cf.time_id;

-- 2. Redo question C.1 above, instead of using cumulative aggregate, 
-- use moving aggregate to show the following results moving aggregate of 3 
-- monthly. (Hints: Use ROWS 2 PRECEDING).
select cf.time_id, 
       sum(cf.revnue) as Total_Revenue,
       TO_CHAR(avg(SUM(cf.revnue)) OVER(ORDER BY cf.time_id ROWS 2 PRECEDING), '9,999,999.99') AS Moving_3_Month_AVG
from charter_fact cf
where cf.TIME_ID like '1995%'
group by cf.time_id;

-- 4. Display the cumulative total fuel used based on the year, and another 
-- cumulative total used for each airplane model.
select td.time_year, cf.mod_code,
       sum(cf.TOTAL_FUEL) as Total_Fuel,
       to_char(sum(sum(cf.TOTAL_FUEL)) over (PARTITION BY td.time_year order by td.time_year ROWS UNBOUNDED PRECEDING), '9,999,999.99') as Acumulative_Fuel_By_Year,
       to_char(sum(sum(cf.TOTAL_FUEL)) over (PARTITION BY cf.mod_code order by cf.mod_code ROWS UNBOUNDED PRECEDING), '9,999,999.99') as Acumulative_Fuel_By_Model
from time_dim td, charter_fact cf
where td.time_id = cf.time_id
group by td.time_year, cf.mod_code
order by td.time_year;




























