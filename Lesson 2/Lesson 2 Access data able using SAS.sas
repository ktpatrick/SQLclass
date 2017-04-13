/*This file links to a sql server management studio database and queries the data using a proc sql statement*/

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
libname NASSQS 		ODBC NOPROMPT="FILEDSN=&NASSQuickstatsdsn;"  	schema=NASSQSFTP;


Proc Sql;
	/*This proc sql statement selects every column from the st table in the lookups schema, in the FarmIncomeInternal database,
		in the SQLprod01 server*/
	Select *
	From lookups.st;
Quit;


/*A Substring helps select data from the middle of the value.*/
Proc Sql;
	Select Substring ('New Hampshire' From 5 For 4) as UsingSubstring,
			substr('New Hampshire',5,4) as UsingSubstr,
			substr(StateName,5,4) as UsingSubstrWVariable
	from lookups.st;
Quit;


/*Below is an example of how to eliminate spaces in front of or behind a character.
Datalines insert data directly into the program. This allows the user to build additional information
and show how other functions work.*/
Data Example;
   input string $char9.;
   original = '*' || string || '*';
   stripped = '*' || strip(string) || '*';
   datalines;
State
  State
    State
  S  T  
Run;

Proc print data=Example;
Run;


/*This creates a table that refers to the column alias (StateRegion) in the Order By statement.*/
/*There are many ways to concatenate variables like in the previous lesson.*/
/*(ie.) ST||'_'||'US', Cat(ST,'_', 'US'), Cats(St,'_', 'US'), Catx('_',ST, 'US').*/
Proc Sql;
	Select
	StateName  ||', '|| TenRegionCode as StateRegion
	from lookups.st
	Order by StateRegion;
Quit;

/*Below is an example of a composite function. This is when you combine two or more functions together.
The first and third set of concatenation's is also combined with lowcase, which converts all the letters in a value 
to lowercase.*/
Proc Sql;
	Select 	St, TenRegionCode, 
				lowcase(ST||'_'||'US') As StateCountry 'State Country by ||', 
				Cat(ST,'_', 'US') As StateCountry1 'State Country by Cat()', 
				lowcase(Cats(St,'_', 'US')) As StateCountry2 'State Country by Cats()', 
				Catx('_',ST, 'US') As StateCountry3 'State Country by Catx()'
	from lookups.st;
Quit;


*********************************************************;
/*Numeric Function examples.*/

/*Ignore the code below. It will run and make the dataset that is used to demonstrate this weeks examples.*/
/*We'll learn more about this code next week.*/
Proc SQl;
	Create Table LandData As
	Select STATE_ALPHA As St, 
			Case Short_Desc
				When 'FARM OPERATIONS - ACRES OPERATED' Then 'Acres'
				When 'AG LAND, INCL BUILDINGS - ASSET VALUE, MEASURED IN $ / ACRE' Then 'PricePerAcre'
			End As Variable,
		Value_Numeric As Amount
	From NassQS.NASS_Quickstats_Survey
	Where 	Domain_Desc='TOTAL' AND 
			SHORT_DESC IN ( 'AG LAND, INCL BUILDINGS - ASSET VALUE, MEASURED IN $ / ACRE', 'FARM OPERATIONS - ACRES OPERATED') And
			Reference_Period_Desc='YEAR' AND 
			AGG_LEVEL_DESC IN ('STATE') AND 
			Input(Year,4.)=2015
	Order By St;
Quit;
/*Continue to ignore this.*/
Proc Transpose Data=LandData Out=LandDataWide (Drop= _Name_ _Label_);
	By St;
	Var Amount;
	Id Variable;
Run;

/*This starts the numeric examples. Stop ignoring the code now.*/
Proc Sql;
	/*We might like to know the US totals for these items.*/
	Select 	Sum(Acres) As US_Acreage, 
			Sum(Acres*PricePerAcre) As ContigousUSLandValue
	From LandDataWide;
	/*It is also interesting to look at the states with the maximum and minimum values.*/
	Select 	St, Min(Acres) As LowestAcres
	From LandDataWide;

	Select St, Max(Acres) As MaximumAcres
	From LandDataWide;

	Select 	St, Min(PricePerAcre) As LowestAcres
	From LandDataWide;
	Select St, Max(PricePerAcre) As MaximumAcres
	From LandDataWide;
Quit;

/*This demonstrates that SAS will allow the sum function to sum across rows when you specify more than 1 column.*/
/*In SQL management studio, the sum function just sums a single column.*/
Proc Sql;
	/*Here we also compare the + sign operator vs. the Sum() function in SAS.*/
		/*The + operator returns null value when a null value is part of the calculation.*/
		/*The Sum() function ignores the missing value and returns the resulting value from the calculation.*/
	Select 	Acres+PricePerAcre As Sum1,
			Sum(Acres,PricePerAcre) As Sum2
	From LandDataWide;
Quit;

/*Next we can look at performing a more relevant example using what we've learned so far.*/
Proc Sql;
	/*This returns the query results as a SAS dataset in the work library.*/
	Create Table TotalLandData As
		Select 	Sum(Acres) As US_Acreage 'US Acres', 
				Sum(Acres*PricePerAcre) As ContigousUSLandValue '48 State land value'
		From LandDataWide;
	/*This uses the Summed land value data, which we type in the query as a constant 'literal' column.*/
	/*In two weeks we'll learn how to join tables and do this in one step.*/
	Select  St, 
			Acres, 
			PricePerAcre, 
			Acres*PricePerAcre As LandValue 'State land value', 
			2.7363979E12 As ContigousUSLandValue '48 State land value',
			((Acres*PricePerAcre)/2.7363979E12)*100 As PercentContigousLandValue '% of 48 State land value'
	From LandDataWide;

	/*We can automatically make this a SAS dataset using the Create Table statement.*/
	Create Table LandDataCalcs As
		Select  St, 
			Acres, 
			PricePerAcre, 
			Acres*PricePerAcre As LandValue 'State land value', 
			2.7363979E12 As ContigousUSLandValue '48 State land value',
			((Acres*PricePerAcre)/2.7363979E12)*100 As PercentContigousLandValue '% of 48 State land value'
		From LandDataWide;
Quit;



***************************************************************;
/*This creates a table that sorts the data in ascending order by the TenRegionCode column.*/
/*ASC-Ascending DESC-Descending*/
Proc Sql;
	Select StateName, FiveRegionCode, TenRegionCode
	from lookups.st
	Order by TenRegionCode ASC;

	Select StateName, FiveRegionCode, TenRegionCode
	from lookups.st
	Order by TenRegionCode Desc;
Quit;

/*ASC is the default when using Order By.*/
/*This table is sorted by TenRegionCode then by StateName.*/
Proc Sql;
	Select StateName, FiveRegionCode, TenRegionCode
	from lookups.st
	Order by TenRegionCode, StateName;
Quit;


/*The Top # command in the select clause that can be used in SQL Server Management Studio can't be used in SAS.*/
/*You have to use the Proc SQL statement option OutObs=# instead.*/
Proc Sql OutObs=5;
	Select StateName, FiveRegionCode, TenRegionCode
	from lookups.st
	Order by TenRegionCode, Fips;
Quit;

