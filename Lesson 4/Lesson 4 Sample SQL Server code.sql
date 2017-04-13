/*This is the sample MS SQL Server Code for
   Week 3: Conditional logic and sub-setting rows*/

--The "Use" statement below tell SQL which database to use
Use FarmIncomeInternal

/*This starts the section on Inner joins.*/
--This shows a basic inner join
	--Here we have a where statement subsetting the results to just show 2014 annual (MM='00') soybean cash receipt values
Select a.YYYY, a.MM, b.StateName, a.Amount
From ERS_wide_access.public_data a
	inner Join [lookups].[st] b
		On a.ST=b.ST
Where Cast(YYYY as Int)=2014 AND MM='00' AND a.St not in ('US') AND
		Concat(Vgroup, Vtype, Vdesc1, Vdesc2)='CRSY--VA' 

--We can also use the knowledge we've learned about using functions and conditional logic in the Select clause.
	--Again we select just the 2014 annual (MM='00') cash receipt values for Soybeans with a where clause
	--We join in the State lookup (descriptor) information.
	--We also join the descriptor information from the units lookup table (you can join more than one table in a query!).
Select YYYY, MM, a.St,b.StateName,
	   Concat(Vtype, Vdesc1) as Commodity,
	   Amount, a.Unit_Num, c.Unit_Desc
From ERS_wide_access.public_data a
	inner Join [lookups].[st] b
		On a.ST=b.ST
	inner Join [lookups].[units] c
		On a.Unit_Num=C.Unit_num
Where Cast(YYYY as Int)=2014 AND MM='00' AND a.St not in ('US') AND
		Concat(Vgroup, Vtype, Vdesc1, Vdesc2)='CRSY--VA' 

--We can also add conditional logic (a Case statement)
	--descriptions to make a collapsed NineRegionCode grouping for the states.
	--Unlike last week, we'll perform conditional logic on Columns from tables were joining.

Select YYYY, MM, a.St,
		Case b.TenRegionCode
			When 'Southern plains' Then 'Plains'
			When 'Northern plains' Then 'Plains'
			Else b.TenRegionCode
		End As NineRegionCode,
	   Concat(Vtype, Vdesc1) as Commodity,
	   Amount, a.Unit_Num, c.Unit_Desc
From ERS_wide_access.public_data a
	inner Join [lookups].[st] b
		On a.ST=b.ST
	inner Join [lookups].[units] c
		On a.Unit_Num=C.Unit_num
Where Cast(YYYY as Int)=2014 AND MM='00' AND a.St not in ('US') AND
		Concat(Vgroup, Vtype, Vdesc1, Vdesc2)='CRSY--VA' 
Order by NineRegionCode Desc, Fips;


--This part covers Outer joins
--This example uses a left join to add stateName to the query result
Select a.YYYY, a.MM, b.StateName, a.Amount
From ERS_wide_access.public_data a
	Left Join [lookups].[st] b
		On a.ST=b.ST
Where Cast(YYYY as Int)=2014 AND MM='00' AND a.St not in ('US') AND
		Concat(Vgroup, Vtype, Vdesc1, Vdesc2)='CRSY--VA' 

--This example uses a right join to add stateName to the query result
--it is much less intuitive, use left join instead
Select a.YYYY, a.MM, b.StateName, a.Amount
From [lookups].[st] b
	right Join ERS_wide_access.public_data a
		On a.ST=b.ST
Where Cast(YYYY as Int)=2014 AND MM='00' AND a.St not in ('US') AND
		Concat(Vgroup, Vtype, Vdesc1, Vdesc2)='CRSY--VA' 


--Set logic examples

--This example uses the union statement to combine the results from two queries and eliminates duplicates
--You could use the union all keywords to include duplicates
Select a.YYYY, a.MM, b.StateName, Concat(Vgroup, Vtype, Vdesc1, Vdesc2) as Variable,'Soybeans' as VariableName, a.Amount
From ERS_wide_access.public_data a
	inner Join [lookups].[st] b
		On a.ST=b.ST
Where Cast(YYYY as Int)=2014 AND MM='00' AND a.St in ('US') AND
		Concat(Vgroup, Vtype, Vdesc1, Vdesc2)='CRSY--VA' 
union

Select a.YYYY, a.MM, b.StateName,Concat(Vgroup, Vtype, Vdesc1, Vdesc2) as Variable,'Corn' as VariableName, a.Amount
From ERS_wide_access.public_data a
	inner Join [lookups].[st] b
		On a.ST=b.ST
Where Cast(YYYY as Int)=2014 AND MM='00' AND a.St in ('US') AND
		Concat(Vgroup, Vtype, Vdesc1, Vdesc2)='CRCR--VA' 
order by yyyy

--This example uses the intersect statement to return rows that are in both select statements
-- here we see the years we have data for and the years we have GDP deflator data for
--notice that the result is not ordered. We will need to learn about subqueries to order results like this
Select distinct YYYY 
From ERS_wide_access.public_data

intersect
select distinct YYYY
From [BEA_NIPA].[GDP_chained_price_index]


--We can use except keyword to see the years we have data for but no GDP deflator data
Select distinct YYYY 
From ERS_wide_access.public_data
except
select distinct YYYY
From [BEA_NIPA].[GDP_chained_price_index]
order by yyyy

Select YYYY, MM, artificialKey, vgroup, st, vtype, vdesc1, vdesc2, sens, unit_num
From [newfarminc].[source_data]
except 
Select YYYY, MM, artificialKey, vgroup, st, vtype, vdesc1, vdesc2, sens, unit_num
From ERS_wide_access.public_data