/*This is the sample MS SQL Server Code for
   Week 3: Conditional logic and sub-setting rows*/

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

/*This starts the section on conditional column logic.*/
/*For the first example, suppose we want to use our existing TenRegionCode*/
/*	--descriptions to make a collapsed NineRegionCode grouping for the states*/

/*--We can use a simple format case statement to accomplish this*/
/*	-- Note: The syntax for this is the same in MS SQL Server and in SAS Proc SQL*/
Proc Sql;
	Select St, Fips, TenRegionCode,
			Case TenRegionCode
				When 'Southern plains' Then 'Plains'
				When 'Northern plains' Then 'Plains'
				Else TenRegionCode
			End As NineRegionCode
	From lookups.st
	Order by NineRegionCode Desc, Fips;

/*	--We could have also used a search format case statement to get same result*/
/*	-- Note: The syntax for this is the same in MS SQL Server and in SAS Proc SQL*/
	Select St, Fips, TenRegionCode,
			Case 
				When TenRegionCode in ('Southern plains','Northern plains') Then 'Plains'
				Else TenRegionCode
			End As NineRegionCode
	From lookups.st
	Order by NineRegionCode Desc, Fips;
Quit;

/*This starts the section on sub-setting rows.*/

/*--First we'll look at subsetting rows by position.*/
/*	--Last week we covered the MS SQL Server specific "Top" keyword*/
Proc Sql  outobs=2;
	Select*
	From lookups.St
	Order By Fips;
Quit;


/*-Next we'll look at subsetting rows by uniqueness.*/
/*--Suppose you are responsible for farm income and wealth data and get the following two ?'s*/
/*	-- What years do you have data for?*/
/*	-- What commodities do you have cash receipt (i.e.: revenue) data for? */


/*--We can answer Q1 by getting the unique years (column YYYY) from our data table*/
/*	-- Note: The syntax for this is the same in MS SQL Server and in SAS Proc SQL.*/
Proc Sql;
	Select Distinct YYYY
	From ErsWide.public_data;
quit;

/*--But Q2 and Q3 will have to wait, b/c we'll need to use distinct and a where clause.*/
/*--We'll come back to that in a minute.*/

/*--Finally we'll look at sub-setting rows using a where clause*/
/*	--Let's start answering Q2 and Q3*/
/*--We Know from our data that Vgroup defines the type of broad data category*/
/*	-- 'CR' is the Vgroup code for Commodity cash receipts*/
/*	-- The two columns Vtype and Vdesc1 define a commodity*/
/*	-- The column Vdesc2 defines whether the data is the revenue value (P*Q), commodity price or quantity*/

/*--Using a Where clause subsets the rows in the table, returning just those where Vgroup='CR'*/
Proc Sql;
	Select *
	From ErsWide.public_data
	Where Vgroup='CR';
Quit;

/*--But there are still 271,830 results, which isn't what we want.*/
/*	--We can also use distinct in the select clause. */
/*	--Distinct clause works in MS SQL Server and SAS Proc SQL.*/
/*	--Note: the concat function is MS SQL Server specific, the syntax in SAS is different.*/
Proc Sql;
	Select Distinct Concat(Vtype,Vdesc1) As Commodity
	From ERSwide.public_data
	Where Vgroup='CR'
	Order By Concat(Vtype,Vdesc1);
Quit;


/*--We see there are 287 distinct commodities in our database, answering the question.
	--Of course, you'd need to know what things like AC-- and AP-- actually mean.
		--In the relational database set-up, descriptive names are stored in another table.
		--Next week we'll learn how to join tables to accomplish this.*/

/*--What if we want to know which commodities we have price data on?*/
/*	--We can use a simple compound Where clause		*/
Proc Sql;
	Select Distinct Concat(Vtype,Vdesc1) As Commodity
	From ErsWide.public_data
	Where Vgroup='CR' AND vdesc2='PR'
	Order By Concat(Vtype,Vdesc1);
Quit;

/*--Of the 287 commodities we have price data on 211. */


/*--Finally, let's look at 1 slightly more complex Where clause
	--Here we use compound operators ("And", "Or") as well as in and Between
--This selects Average calendar year price data from 2008-2014 for:
	--Illinois Soybeans, Georgia Peanuts, and Texas Cattle/Calves
--First we rely on operator precedence (AND is highe precedence than OR) for correct results*/

Proc Sql;
	Select	*
	From	ERSwide.public_data
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
	Order By St, YYYY;


/*--Next we use paranthesis for clarity*/
	Select	*
	From	ERSwide.public_data
	Where	(Vgroup='CR' AND 
			Vtype in ('SY') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='IL' AND
			input(YYYY,8.) Between 2008 and 2014)
			OR
			(Vgroup='CR' AND 
			Vtype in ('CL') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='TX' AND
			input(YYYY,8.) Between 2008 and 2014)
			OR
			(Vgroup='CR' AND 
			Vtype in ('PN') AND
			Vdesc1='--' AND
			vdesc2='PR' AND 
			St='GA' AND
			input(YYYY,8.) Between 2008 and 2014)
	Order By St, YYYY;
Quit;
Proc sql;
/*--Finally we show a collapsed version*/
	Select	*
	From	ERSwide.public_data
	Where	(Vgroup='CR' AND input(YYYY,8.) Between 2008 and 2014 AND Vdesc2='PR') 
			AND
			(( Vtype||Vdesc1 in ('SY--') And St='IL' )
				OR
			 ( Vtype||Vdesc1 in ('CL--') And St='TX' )
				OR 
			 ( Vtype||Vdesc1 in ('PN--') And St='GA' ))
	Order By St, YYYY;
Quit;