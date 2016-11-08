-- (a)
select student_id, count(student_id) as NumOfOccur
from student
group by student_id
having NumOfOccur > 1;


-- (b)
select * 
from dw.uselog
where student_id not in (
						 select student_id
						 from dw.student
						 );


-- (a)
select ld.city, od.sourceID, sd.S_desc, 
       sum(cf.toq), sum(cf.toc)
from locationDim ld, OsourceDim od, 
      SeasonDim sd, ClothingCompanyFact cf
where lfdkfdljkds
and fjlfdjlfdsklj
and jfdjklfdjl
group by cube (ld.city, od.sourceID, sd.S_desc);

-- (b)
select ld.city, od.sourceID, sd.S_desc, 
       sum(cf.toq), sum(cf.toc)
from locationDim ld, OsourceDim od, 
      SeasonDim sd, ClothingCompanyFact cf
where lfdkfdljkds
and fjlfdjlfdsklj
and jfdjklfdjl
group by rollup (ld.city, od.sourceID, sd.S_desc);

-- (c)
select ld.city, cf.sourceID, sd.S_desc, 
       sum(cf.TotalOrderCost), 
       to_char(sum(sum(cf.TotalOrderCost)) over
       	 (order by ld.city, sd.S_desc 
       	 	rows bounded preceding),
       	 '999,999,999,99') as XXXXXXXXX
from locationDim ld, 
	 SeasonDim sd, ClothingCompanyFact cf
where lfdkfdljkds
and fjlfdjlfdsklj
and jfdjklfdjl
group by rollup (ld.city, cf.sourceID, sd.S_desc);

-- (d)
Select O.SourceID, l.city, s.S_Desc, 
	   sum(TotalOrderCost), 
	   TO_CHAR(SUM(SUM(TotalOrderCost))
	   OVER(PARTITION BY O.SourceID, L.City
	   ORDER BY l.city, s.S_Desc 
	   ROWS UNBOUNDED PRECEDING), '9,999,999.99') 
	   AS Cummulative_Total_Order_Cost
from LocationDim l, 
	 OsourceDim o, 
	 ClothingCompanyFact c 
where l.CLocationID = c.CLocationID
and s.SeasonID = c.SeasonID
group by (O.SourceID, l.city, s.S_Desc);


--------------------------------------------------
select ld.city, cf.sourceID, sd.S_desc,
	   sum(cf.TotalOrderCost),
	   to_char(sum(sum(cf.TotalOrderCost))
	   over (partition by ld.city, cf.sourceID
	   order by ld.city, cf.sourceID
	   rows bounded preceding), '999,999,999,99')
	   as Cummulative_Total_Order_Cost
from locationDim ld,
	 SeasonDim sd,
	 ClothingCompanyFact cf
where ld.CLocationID = cf.CLocationID
and cf.SeasonID = sd.SeasonID
group by ld.city, cf.sourceID, sd.S_desc;

-- (e)
select cf.sourceID, 
	   sum(cf.TotalOrderCost) as TotalOrderCost
	   rank() over 
	   (order by sum(cf.TotalOrderCost) desc)
	   as TheRank
from ClothingCompanyFact cf
group by cf.sourceID;

-- (f)
select *
from (select cf.sourceID, 
	   sum(cf.TotalOrderCost) as TotalOrderCost
	   rank() over 
	   (order by sum(cf.TotalOrderCost) desc)
	   as TheRank
from ClothingCompanyFact cf
group by cf.sourceID)
where TheRank <= 1;

-- Question 7

-- (a. Show the top 3 total number of auctions by time sessions.)
select *
from (select td.time_session,
			 sum(ft.Total_No_of_Auction) as TNoA,
			 rank() over 
			 (order by sum(ft.Total_No_of_Auction) desc)
			 as TheRank
	  from TimeDim td, FactTable ft
	  where td.time_id = ft.time_id
	  group by td.time_session
	 )
where TheRank <= 3;

-- (b)
select decode(grouping(md.Month_desc), 1,
	   "All Months", md.Month_desc) as Month,
	   decode(grouping(ld.RegionName), 1,
	   "All Regions", ld.RegionName) as Region,
	   sum(ft.Total_No_of_Auction) as TNoA
from MonthDim md, 
	 LocationDim ld,
	 FactTable ft
where ft.month_id = md.month_id
and ft.locationid = ld.locationid
group by rollup (md.Month_desc, ld.RegionName);

-- (c)
select id.item_name, 
	   sum(ft.total_profit) as x1,
	   sum(ft.total_payment) as x2,
	   sum(ft.Total_No_of_Auction) as x3,
	   to_char(sum(sum(ft.total_profit)) 
	   over (partition by id.item_name 
	   order by id.item_name
	   rows bounded preceding),
	   '99,999,999,99') as y1,
	   to_char(sum(sum(ft.total_payment))
	   over (partition by id.item_name
	   order by id.item_name 
	   rows bounded preceding),
	   '99,999,999,99') as y2,
	   to_char(sum(sum(ft.Total_No_of_Auction))
	   over (partition by id.item_name
	   order by id.item_name 
	   rows bounded preceding),
	   '99,999,999,99') as y3
from itemDim id, FactTable ft
where id.itemkey = ft.itemkey
group by id.item_name;
