/*This is the sample MS SQL Server Code for
   Week 3: Conditional logic and sub-setting rows*/

--The "Use" statement below tell SQL which database to use
Use FarmIncomeInternal

/*This starts the section on conditional column logic.*/
--For the first example, suppose we want to use our existing TenRegionCode
	--descriptions to make a collapsed NineRegionCode grouping for the states

--We can use a simple format case statement to accomplish this
	-- Note: The syntax for this is the same in MS SQL Server and in SAS Proc SQL
Select St, Fips, TenRegionCode,
		Case TenRegionCode
			When 'Southern plains' Then 'Plains'
			When 'Northern plains' Then 'Plains'
			Else TenRegionCode
		End As NineRegionCode
From lookups.st
Order by NineRegionCode Desc, Fips;

--We could have also used a search format case statement to get same result
	-- Note: The syntax for this is the same in MS SQL Server and in SAS Proc SQL
Select St, Fips, TenRegionCode,
		Case 
			When TenRegionCode in ('Southern plains','Northern plains')
					 Then 'Plains'
			Else TenRegionCode
		End As NineRegionCode
From lookups.st
Order by NineRegionCode Desc, Fips;

/*This starts the section on sub-setting rows.*/

--First we'll look at subsetting rows by position.
	--Last week we covered the MS SQL Server specific "Top" keyword
Select Top 2 *
From lookups.St
Order By Fips

--This week we'll generalize this to the ANSI standard Offset-Fetch filtering method
	--Running both queries, we see that they return the same result.
	--Neither top or Offset-Fetch filtering works in SAS Proc SQL. 
	--We'll show a different method in SAS example code to use with Proc SQL.
Select *
From Lookups.St
Order By Fips
Offset 0 Rows Fetch Next 2 Rows only;

--Offset-Filtering also allows you to select a given number of rows 
	--while starting with a row other than the first row
Select *
From Lookups.St
Order By Fips
Offset 5 Rows Fetch Next 17 Rows only;

--Next we'll look at subsetting rows by uniqueness.
--Suppose you are responsible for farm income and wealth data and get the following two ?'s
	-- What years do you have data for?
	-- What commodities do you have cash receipt (i.e.: revenue) data for? 


--We can answer Q1 by getting the unique years (column YYYY) from our data table
	-- Note: The syntax for this is the same in MS SQL Server and in SAS Proc SQL.
Select Distinct YYYY
From ERS_wide_access.public_data;

--But Q2 and Q3 will have to wait, b/c we'll need to use distinct and a where clause.
--We'll come back to that in a minute.

--Finally we'll look at sub-setting rows using a where clause
	--Let's start answering Q2 and Q3
--We Know from our data that Vgroup defines the type of broad data category
	-- 'CR' is the Vgroup code for Commodity cash receipts
	-- The two columns Vtype and Vdesc1 define a commodity
	-- The column Vdesc2 defines whether the data is the revenue value (P*Q), commodity price or quantity

--Using a Where clause subsets the rows in the table, returning just those where Vgroup='CR'
Select *
From ERS_wide_access.public_data
Where Vgroup='CR'

--But there are still 271,830 results, which isn't what we want.
	--We can also use distinct in the select clause. 
	--Distinct clause works in MS SQL Server and SAS Proc SQL.
	--Note: the concat function is MS SQL Server specific, the syntax in SAS is different.
Select Distinct Concat(Vtype,Vdesc1) As Commodity
From ERS_wide_access.public_data
Where Vgroup='CR'
Order By Concat(Vtype,Vdesc1)

--We see there are 287 distinct commodities in our database, answering the question.
	--Of course, you'd need to know what things like AC-- and AP-- actually mean.
		--In the relational database set-up, descriptive names are stored in another table.
		--Next week we'll learn how to join tables to accomplish this.

--What if we want to know which commodities we have price data on?
	--We can use a simple compound Where clause		
Select Distinct Concat(Vtype,Vdesc1) As Commodity
From ERS_wide_access.public_data
Where Vgroup='CR' AND vdesc2='PR'
Order By Concat(Vtype,Vdesc1)

--Of the 287 commodities we have price data on 211. 


--Finally, let's look at 1 slightly more complex Where clause
	--Here we use compound operators ("And", "Or") as well as in and Between
--This selects Average calendar year price data from 2008-2014 for:
	--Illinois Soybeans, Georgia Peanuts, and Texas Cattle/Calves
--First we rely on operator precedence (AND is highe precedence than OR) for correct results
Select	*
From	ERS_wide_access.public_data
Where	Vgroup='CR' AND 
		Vtype in ('SY') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='IL' AND
		Cast(YYYY as int) Between 2008 and 2014
		OR
		Vgroup='CR' AND 
		Vtype in ('CL') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='TX' AND
		Cast(YYYY as int) Between 2008 and 2014
		OR
		Vgroup='CR' AND 
		Vtype in ('PN') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='GA' AND
		Cast(YYYY as int) Between 2008 and 2014
Order By St, YYYY


--Next we use paranthesis for clarity
Select	*
From	ERS_wide_access.public_data
Where	(Vgroup='CR' AND 
		Vtype in ('SY') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='IL' AND
		Cast(YYYY as int) Between 2008 and 2014)
		OR
		(Vgroup='CR' AND 
		Vtype in ('CL') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='TX' AND
		Cast(YYYY as int) Between 2008 and 2014)
		OR
		(Vgroup='CR' AND 
		Vtype in ('PN') AND
		Vdesc1='--' AND
		vdesc2='PR' AND 
		St='GA' AND
		Cast(YYYY as int) Between 2008 and 2014)
Order By St, YYYY

--Finally we show a collapsed version
Select	*
From	ERS_wide_access.public_data
Where	(Vgroup='CR' AND Cast(YYYY as int) Between 2008 and 2014 AND Vdesc2='PR') 
		AND
		(( Vtype+Vdesc1 in ('SY--') And St='IL' )
			OR
		 ( Vtype+Vdesc1 in ('CL--') And St='TX' )
			OR 
		 ( Vtype+Vdesc1 in ('PN--') And St='GA' ))
Order By St, YYYY
