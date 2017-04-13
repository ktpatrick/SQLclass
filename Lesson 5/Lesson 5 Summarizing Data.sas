/*This is the sample MS SQL Server Code for
   Week 5: Summarizing Data*/

/*This is the location of the dsn file that contains info used by SAS to access a particular database*/
/*[ODBC]*/
/*DRIVER=SQL Server*/
/*DATABASE=FarmIncomeInternal*/
/*Trusted_Connection=Yes*/
/*SERVER=SQLProd01*/
%LET FarmIncomeInternaldsn = \\d04nt04\FarmIncome\shared\FarmIncomeInternal\FarmIncomeInternal.dsn; 
%LET NASSQuickstatsdsn = \\d04nt04\FarmIncome\shared\FarmIncomeInternal\NASSQUICKSTATS.dsn;
/*The libname statement creates a library location for the particular schema in the database referenced in the dsn file*/
libname lookups 	ODBC NOPROMPT="FILEDSN=&FarmIncomeInternaldsn;" schema=lookups;
libname nfarminc 	ODBC NOPROMPT="FILEDSN=&FarmIncomeInternaldsn;" schema=newfarminc;
libname ErsWide 	ODBC NOPROMPT="FILEDSN=&FarmIncomeInternaldsn;" schema=ERS_wide_access;
libname NASSQS 		ODBC NOPROMPT="FILEDSN=&NASSQuickstatsdsn;"  	schema=NASSQSFTP;

/*This starts the section on Count funtions.*/
/*There are three different ways to use the count function.*/
/*This first example counts all of the selected rows that are also subsetted by the where clause statement.*/
/*This specifies the price of all soybeans from 2010-2014 in Illinois.*/

Proc Sql;
	select
	Count (*) as NumberofSoybeans
	from ERSwide.public_data
	where Vgroup='CR' AND 
			Vtype in ('SY') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='IL' AND
			input(YYYY,8.) Between 2010 and 2014;
Quit;

/*The second example specifies a specific column rather than the asterisk.*/

Proc Sql;
	select
	count(Vtype) as NumberofSoybeans
	from ERSwide.public_data
	where Vgroup='CR' AND 
			Vtype in ('SY') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='IL' AND
			input(YYYY,8.) Between 2010 and 2014;
Quit;

/*The last example for the count function uses the Distinct keyword to
return different values within a column.*/
/*This will return 177 unique variables within the Vtype column.*/

Proc Sql;
	select
	Count(Distinct Vtype) as DataTypes
	from ERSwide.public_data;
Quit;

/*The next set of useful summarizing functions are Sum, Avg, Max, and Min.*/
/*We have a few questions that we want to answer for our co-worker.*/
/*Q1: What if we wanted to know what was the most recent year we have data for soybeans?*/
/*Q2: What is the Avg price  for peanuts in Georgia?*/
/*Q3: What is the total sales amount for peanuts in Georgia between 2006-2014?*/

/*We use the max function in the select statement to specifiy our condition.*/
/*This results with soybean data in the year of 2016 only once because of the Distinct keyword.*/

Proc Sql;
	select Distinct(Max(yyyy))
	from ERSwide.public_data
	where Vtype='SY';
Quit;

/*Q2: What is the Avg  price data for peanuts in Georgia?*/
/*We'll use the average function for this.*/
Proc Sql;
	select Avg(amount) as AvgPrice 'Average Peanut price in Georgia'
	from ERSwide.public_data
	where Vgroup='CR' AND 
			Vtype in ('PN') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='GA' And mm='00';
Quit;


/*Q3: What is the total sales of peanuts in Georgia between 2006-2014?*/


Proc Sql;
	select Sum(amount) as Total
	from ERSwide.public_data
	where Vgroup='CR' AND 
			Vtype in ('PN') AND
			Vdesc1='--' AND
			vdesc2='VA' AND 
			St='GA' And input(YYYY,8.) Between 2006 and 2014;	
Quit;


/*This starts the Group by function.*/
/*Let's answer questions 1-3 from above, but for all states.*/
/*Q1: What if we wanted to know what was the most recent year we have data for soybeans?*/

/*Running the query below using the group by clause, we can see the answer easily.*/
/*It turns out we just have US level data (forecasts) for 2016 and state data through 2014.*/
/*IF we just want to see forecast data (YYYY >=2015) we can use a having clause to subset the groups.*/
Proc Sql;
	Select Distinct St, (Max(yyyy)) As DataYear
	from ERSwide.public_data
	where Vtype='SY'
	Group By St
	Order By Max(YYYY) Desc, St;
Quit;

/*What if we wanted to report the average price for peanuts in any state by year instead of a total summation.*/
/*Using the Group by function helps to separate the price totals by year.*/
/*Like distinct, the group by clause creates unique combos. Then puts the rows into those combination bins.*/
Proc Sql;
	Select Distinct St, (Max(yyyy)) As DataYear
	from ERSwide.public_data
	where Vtype='SY'
	Group By St
	Having (Max(yyyy)) >= 2015
	Order By Max(YYYY) Desc, St;
Quit;


/*Q2: What is the Avg price  for peanuts in from 2006 to 2014 by state?*/
/*Using the Group by function seperates the average prices by state.*/
/*Like distinct, the group by clause creates unique combos. Then puts the rows into those combination bins.*/

Proc SQL;
	select St, Avg(amount) as AvgPrice
	from ERSwide.public_data
	where  Vgroup='CR' AND 
			Vtype in ('PN') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			mm='00'
	Group By St
	Order By AvgPrice Desc;
Quit;
/*Q3: What is the total sales amount for peanuts in By State from between 2006-2014?*/
Proc SQl;
	select St, Sum(amount) as Total 
	from ERSwide.public_data
	where Vgroup='CR' AND 
			Vtype in ('PN') AND
			Vdesc1='--' AND
			vdesc2='VA' AND 
			St Not in ('US') AND
			Input(YYYY,4.) Between 2006 and 2014
	Group By St
	Order By Total Desc;
Quit;





***********************;
***********************;


/*Looking at the price total is just a value and may not mean much to you.*/
/*We want to know what the units are for this value so we will need 
combine the lookups.units table.*/
/*Using a Left join will help solve this issue.*/

/*Note: Below we include a column in the select clasue tha varies by YYYY (the column is Vtype).
		As a result, we don't get the sum we wanted.*/
Proc Sql;
	select 	sum(amount) as Total, unit_desc, yyyy, 
			Vgroup, Vtype, Vdesc1, Vdesc2, st
	from ERSwide.public_data a
	Left join lookups.units b
		On public_data.Unit_num=units.unit_num
	where Vgroup='CR' AND 
			Vtype in ('PN', 'PE') AND
			Vdesc1='--' AND
			vdesc2='VA' AND 
			St='GA' And input(YYYY,8.) Between 2006 and 2014
	Group by yyyy
	Order by yyyy;	
Quit;

/*To get the sum we wanted we need to omit the Vtype column, so nothing in the select clause varies by YYYY.*/
Proc Sql;
	select 	sum(amount) as Total, unit_desc, yyyy, 
			Vgroup, 'Peanut and Pecan sales' As Variable,  st
	from ERSwide.public_data a
	Left join lookups.units b
		On public_data.Unit_num=units.unit_num
	where Vgroup='CR' AND 
			Vtype in ('PN', 'PE') AND
			Vdesc1='--' AND
			vdesc2='VA' AND 
			St='GA' And input(YYYY,8.) Between 2006 and 2014/* And
			b.Unit_num=22 */
	Group by yyyy, b.Unit_desc, Vgroup, St
	Order by yyyy;	
Quit;

/*Now we want to know the average price for different Cash Receipts by specific 
states over the years of 2008-2014.*/
/*Therefore, we create a where clause to subset the specific rows that we want returned.*/

Proc Sql;
	Select	YYYY, Artificialkey, St, Unit_Desc, Avg(amount)as Total
	From	ERSwide.public_data
		Left join lookups.units b
		On public_data.Unit_num=units.unit_num
	Where	Vgroup='CR' AND 
			Vtype in ('SY') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='IL' AND
			input(YYYY,8.) Between 2008 and 2014
			OR
			Vgroup='CR' AND 
			Vtype in ('CL') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='TX' AND
			input(YYYY,8.) Between 2008 and 2014
			OR
			Vgroup='CR' AND 
			Vtype in ('PN') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='GA' AND
			input(YYYY,8.) Between 2008 and 2014
	Group by yyyy, St,  Artificialkey, Unit_Desc
	Order By St, YYYY;
Quit;


/*This starts the Having funciton.*/
/*We get a wide variety of price totals for the SY, CL, and PN.*/
/*For this output, we get asked to only return values greater than 1.*/
/*The Having clause helps return all the values for the variables greater than 1.*/
Proc Sql;
	Select	YYYY, Artificialkey, St, Unit_Desc, Sum(amount)as Total
	From	ERSwide.public_data
		Left join lookups.units b
		On public_data.Unit_num=units.unit_num
	Where	Vgroup='CR' AND 
			Vtype in ('SY') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='IL' AND
			input(YYYY,8.) Between 2008 and 2014
			OR
			Vgroup='CR' AND 
			Vtype in ('CL') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='TX' AND
			input(YYYY,8.) Between 2008 and 2014
			OR
			Vgroup='CR' AND 
			Vtype in ('PN') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='GA' AND
			input(YYYY,8.) Between 2008 and 2014
	Group by yyyy, St,  Artificialkey, Unit_Desc
	Having Sum(amount)>=1
	Order By St, YYYY;
Quit;












