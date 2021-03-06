/****** Script for SelectTopNRows command from SSMS  ******/
Use [FarmIncomeInternal]

Go

--Example 1: A basic in-line view (sub-query in from clause)
SELECT  YYYY, TenRegionCode, 'Acreage' As Variable, Sum(Amount) As RegionTotal
FROM	(	Select YYYY, a.st, vgroup, vtype, Vdesc1, Vdesc2, Amount, b.TenRegionCode
			From [FarmIncomeInternal].[ERS_wide_access].[public_data] a
				Left Join Lookups.St b
					On a.st=b.St
			Where vgroup='FI' AND vtype='FL' and vdesc1='--' and vdesc2='QN' ) a
Group By YYYY, TenRegionCode

--Example 2: A basic sub-query in a select clause
/*Here we return the US acreage in 2014 as a single value and use it as a literal in the select clause
	Every row gets the same value.*/
Select YYYY,st, vgroup, vtype, Vdesc1, Vdesc2, Amount As StateAmount, 
		(	Select Amount
			From [FarmIncomeInternal].[ERS_wide_access].[public_data]
			Where	vgroup='FI' AND vtype='FL' and vdesc1='--' and 
					vdesc2='QN' AND st='US' and YYYY='2014' ) As USTotal
From [FarmIncomeInternal].[ERS_wide_access].[public_data] 
Where vgroup='FI' AND vtype='FL' and vdesc1='--' and vdesc2='QN' and YYYY='2014'

--You can also use the sub-query in a select clause as part of a column calculation
/*Here we calculate each state's acreage as a percent of the US value.*/
Select YYYY,st, vgroup, vtype, Vdesc1, Vdesc2, Amount As StateAmount, 
		(	Select Amount
			From [FarmIncomeInternal].[ERS_wide_access].[public_data]
			Where	vgroup='FI' AND vtype='FL' and vdesc1='--' and 
					vdesc2='QN' AND st='US' and YYYY='2014' ) As USTotal,
		Amount/(	Select Amount
					From [FarmIncomeInternal].[ERS_wide_access].[public_data]
					Where	vgroup='FI' AND vtype='FL' and vdesc1='--' and 
							vdesc2='QN' AND st='US' and YYYY='2014' ) As PCTofUS
From [FarmIncomeInternal].[ERS_wide_access].[public_data] 
Where vgroup='FI' AND vtype='FL' and vdesc1='--' and vdesc2='QN' and YYYY='2014'

--Example 3: Part A - Using a sub-query to return a single value for use in a where clause
/*Here the inner query returns the US average land value per acre
	(it is stored as a row so we don't need to use an average function).*/
/*The outer query then returns the state land value per acre data where the state's value 
	is greater than the US average returned by the sub-query.*/
Select YYYY,st, vgroup, vtype, Vdesc1, Vdesc2, Amount
From [FarmIncomeInternal].[ERS_wide_access].[public_data]
Where vgroup='FI' AND vtype='LV' and vdesc1='LB' and vdesc2='PR' and YYYY='2014' and
	  Amount > (	Select Amount
					From [FarmIncomeInternal].[ERS_wide_access].[public_data]
					Where	vgroup='FI' AND vtype='LV' and vdesc1='LB' and 
							vdesc2='PR' and YYYY='2014' and st='US' ) 
Order By Amount Desc

/*This is the same as if we did the following.*/
Select YYYY,st, vgroup, vtype, Vdesc1, Vdesc2, Amount
From [FarmIncomeInternal].[ERS_wide_access].[public_data]
Where vgroup='FI' AND vtype='LV' and vdesc1='LB' and vdesc2='PR' and YYYY='2014' and
	  Amount > (	2950 ) 
Order By Amount Desc

--Example 3: Part B - Using a sub-query to return a list of values for use in a where clause
/*Here the inner query returns the list of states in the Midwest region (IA, IL, IN, OH, MN, MI, WI, MO).*/
/*The outer query then returns the state land value per acre data for the states in the midwest 
	that are used by the in operator by the sub-query.*/
Select YYYY,st, vgroup, vtype, Vdesc1, Vdesc2, Amount
From [FarmIncomeInternal].[ERS_wide_access].[public_data]
Where vgroup='FI' AND vtype='LV' and vdesc1='LB' and vdesc2='PR' and YYYY='2014' and
	  St in (	Select St
				From Lookups.St
				Where	FiveRegionCode='Midwest' ) 
Order By Amount Desc

/*This is the same as if we did the following.*/
Select YYYY,st, vgroup, vtype, Vdesc1, Vdesc2, Amount
From [FarmIncomeInternal].[ERS_wide_access].[public_data]
Where vgroup='FI' AND vtype='LV' and vdesc1='LB' and vdesc2='PR' and YYYY='2014' and
	  St in ('IA', 'IL', 'IN', 'OH', 'MN', 'MI', 'WI', 'MO' ) 
Order By Amount Desc