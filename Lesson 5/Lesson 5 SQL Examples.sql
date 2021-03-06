--This just tells SQL which database to use

Use FarmIncomeInternal

/*Before we get to grouped aggregate functions, we'll review aggregate functions.*/
/*There are three different ways to use the count function.*/
/*This first example counts all of the selected rows that are also subsetted by the where clause statement.*/
/*This specifies the price of all soybeans from 2010-2014 in Illinois.*/


select Count (*) as NumberofSoybeans
from [ERS_wide_access].[public_data]
where   Vgroup='CR' AND 
		Vtype in ('SY') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='IL' AND
		Cast(YYYY as int) Between 2010 and 2014;

/*The second example specifies a specific column rather than the asterisk.*/
/*Note: If there are missing values the Count(*) and Count(vtype) can return different counts.*/
select Count (Vtype) as NumberofSoybeans
from [ERS_wide_access].[public_data]
where   Vgroup='CR' AND 
		Vtype in ('SY') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='IL' AND
		Cast(YYYY as int) Between 2010 and 2014;

/*The last example for the count function uses the Distinct keyword to return different values within a column.*/
/*This will return 177 unique variables within the Vtype column.*/

select Count(Distinct Vtype) as DataTypes
from [ERS_wide_access].[public_data];

/*The next set of useful summarizing functions are Sum, Avg, Max, and Min.*/
/*We have a few questions that we want to answer for our co-worker.*/
/*Q1: What if we wanted to know what was the most recent year we have data for soybeans?*/
/*Q2: What is the Avg price  for peanuts in Georgia?*/
/*Q3: What is the total sales amount for peanuts in Georgia between 2006-2014?*/

/*We use the max function in the select statement to specifiy our condition.*/
/*This results with soybean data in the year of 2016 only once because of the Distinct keyword.*/

Select Distinct(Max(yyyy))
from [ERS_wide_access].[public_data]
where Vtype='SY';

/*Q2: What is the Avg  price data for peanuts in Georgia?*/
/*We'll use the average function for this.*/

select Avg(amount) as [Avg Price] 
from [ERS_wide_access].[public_data]
where  Vgroup='CR' AND 
		Vtype in ('PN') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='GA' And mm='00';

/*Q3: What is the total sales of peanuts in Georgia between 2006-2014?*/

select Sum(amount) as Total 
from [ERS_wide_access].[public_data]
where Vgroup='CR' AND 
		Vtype in ('PN') AND
		Vdesc1='--' AND
		vdesc2='VA' AND 
		St='GA' And Cast(YYYY as int) Between 2006 and 2014;


---
---
/*This starts the Group by aggregate functions.*/
/*Let's answer questions 1-3 from above, but for all states.*/
/*Q1: What if we wanted to know what was the most recent year we have data for soybeans?*/
/*Running the query below using the group by clause, we can see the answer easily.*/
Select Distinct St, (Max(yyyy)) As DataYear
from [ERS_wide_access].[public_data]
where Vtype='SY'
Group By St
Order By Max(YYYY) Desc, St;

/*It turns out we just have US level data (forecasts) for 2016 and state data through 2014.*/
/*IF we just want to see forecast data (YYYY >=2015) we can use a having clause to subset the groups.*/
Select Distinct St, (Max(yyyy)) As DataYear
from [ERS_wide_access].[public_data]
where Vtype='SY'
Group By St
Having (Max(yyyy)) >= 2015
Order By Max(YYYY) Desc, St;

/*Q2: What is the Avg price  for peanuts in from 2006 to 2014 by state?*/
/*Using the Group by function seperates the average prices by state.*/
/*Like distinct, the group by clause creates unique combos. Then puts the rows into those combination bins.*/

select St, Avg(amount) as AvgPrice
from [ERS_wide_access].[public_data]
where  Vgroup='CR' AND 
		Vtype in ('PN') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		mm='00'
Group By St
Order By Avg(amount) Desc;

/*Q3: What is the total sales amount for peanuts in By State from between 2006-2014?*/
select St, Sum(amount) as Total 
from [ERS_wide_access].[public_data]
where Vgroup='CR' AND 
		Vtype in ('PN') AND
		Vdesc1='--' AND
		vdesc2='VA' AND 
		St Not in ('US') AND
		Cast(YYYY as int) Between 2006 and 2014
Group By St
Order By Sum(amount) Desc;

--
--
/*This part covers some additional examples.*/
/*Looking at the price total is just a value and may not mean much to you.*/
/*We want to know what the units are for this value so we will need 
combine the lookups.units table.*/
/*Using a Left join will help solve this issue.*/

/*Note: Below we include a column in the select clasue tha varies by YYYY (the column is Vtype).
		As a result, we don't get the sum we wanted.*/

/*We can summarize data on multiple commodities by State in each year.*/
/*Note: That we've included unit_desc in the group by statement (it won't vary by commodity).*/
select 	sum(amount) as Total, unit_desc, yyyy,  st
from [ERS_wide_access].[public_data] a
Left join lookups.units b
	On a.Unit_num=b.unit_num
where  Vgroup='CR' AND 
		Vtype in ('PN', 'PE') AND
		Vdesc1='--' AND
		vdesc2='VA' AND 
		Cast(YYYY as int) Between 2006 and 2014
Group by yyyy, St, b.Unit_Desc
Order by yyyy;	

/*If we remove the St column from the group by clause and select clause 
	we get summaries of the 2 commodity (pecan and peanuts) sales by year.*/
select 	sum(amount) as Total, unit_desc, yyyy, 'All states' As Variable
from [ERS_wide_access].[public_data] a
Left join lookups.units b
	On a.Unit_num=b.unit_num
where  Vgroup='CR' AND 
		Vtype in ('PN', 'PE') AND
		Vdesc1='--' AND
		vdesc2='VA' AND 
		Cast(YYYY as int) Between 2006 and 2014
Group by yyyy, b.Unit_Desc
Order by yyyy;	

/*If we remove the YYYY column from the group by clause and select clause 
	we get summaries of the 2 commodity (pecan and peanuts) sales by State.
	Data is combined over the 2006-2014 period.*/
select 	sum(amount) as Total, unit_desc, St
from [ERS_wide_access].[public_data] a
Left join lookups.units b
	On a.Unit_num=b.unit_num
where  Vgroup='CR' AND 
		Vtype in ('PN', 'PE') AND
		Vdesc1='--' AND
		vdesc2='VA' AND 
		Cast(YYYY as int) Between 2006 and 2014
Group by St, b.Unit_Desc
Order by St;	


/*You can also use group by with a more complex Query like the one with the involved Where statement shown below.*/
/*In the first first example we put all the select columns in the group by (besides the aggregate function column).*/
/*This results in each row being it's own group, so we return the ungrouped data.*/
Select	YYYY, Artificialkey, St, Unit_Desc, Avg(amount)as Total
From	[ERS_wide_access].[public_data] a
	Left join lookups.units b
	On a.Unit_num=b.unit_num
Where	Vgroup='CR' AND 
		Vtype in ('SY') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='IL' AND
		Cast(YYYY as int)  Between 2008 and 2014
		OR
		Vgroup='CR' AND 
		Vtype in ('CL') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='TX' AND
		Cast(YYYY as int)  Between 2008 and 2014
		OR
		Vgroup='CR' AND 
		Vtype in ('PN') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='GA' AND
		Cast(YYYY as int) Between 2008 and 2014
Group by yyyy, St,  Artificialkey, Unit_Desc
Order By St, YYYY;

/*If we want to get a group aggregate like, the average Price By state (over 2008-2014),
   we exclude the appropriate column from the select and group by clauses.*/
Select	Artificialkey, St, Unit_Desc, Avg(amount)as Total
From	[ERS_wide_access].[public_data] a
	Left join lookups.units b
	On a.Unit_num=b.unit_num
Where	Vgroup='CR' AND 
		Vtype in ('SY') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='IL' AND
		Cast(YYYY as int)  Between 2008 and 2014
		OR
		Vgroup='CR' AND 
		Vtype in ('CL') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='TX' AND
		Cast(YYYY as int)  Between 2008 and 2014
		OR
		Vgroup='CR' AND 
		Vtype in ('PN') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='GA' AND
		Cast(YYYY as int) Between 2008 and 2014
Group by St,  Artificialkey, Unit_Desc
Order By St;