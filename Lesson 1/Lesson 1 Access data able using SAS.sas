/*This file links to a sql server management studio database and queries the data using a proc sql statement*/

/*This is the location of the dsn file that contains info used by SAS to access a particular database*/
/*[ODBC]*/
/*DRIVER=SQL Server*/
/*DATABASE=FarmIncomeInternal*/
/*Trusted_Connection=Yes*/
/*SERVER=SQLProd01*/
%LET FarmIncomeInternaldsn = \\d04nt04\FarmIncome\shared\FarmIncomeInternal\FarmIncomeInternal.dsn; 

/*The libname statement creates a library location for the particular schema in the database referenced in the dsn file*/
libname lookups 	ODBC NOPROMPT="FILEDSN=&FarmIncomeInternaldsn;" schema=lookups;
libname nfarminc 	ODBC NOPROMPT="FILEDSN=&FarmIncomeInternaldsn;" schema=newfarminc;

**********************************************************;
/*A basic SQL query requires 2 clauses: Select and From.*/
/*From tells the query where to get the data.*/
/*Select tells the query which columns you want to see.*/
/*The easiest query is one that returns all the columns using the * in the select clause.*/

Proc Sql;
	/*This proc sql statement selects every column from the st table in the lookups schema, in the FarmIncomeInternal database,
		in the SQLprod01 server*/
	Select *
	From lookups.st;
Quit;


**********************************************************;
/*This part shows you how to use the Proc SQL validate option to test the syntax before running.*/
/*Keep in mind this tests syntax, not logic of your query -- it may run, but not neccessarily return what you want.*/
Proc Sql;
	validate
	select *
	from lookups.st;
Quit;

**********************************************************;
/*You can also specify specific columns like the example below.*/
Proc Sql;
	Validate
	Select St, TenRegionCode Fips
	From lookups.st;
Quit;
Proc Sql;
	Select St, TenRegionCode, Fips
	from lookups.st;
Quit;


**********************************************************;
/*You can also create calculated columns within a query.*/
/*Here we run two queries in the same proc sql step. */
/* Each of the two queries creates new column(s) not in the input dataset.*/
Proc SQl;
	/*This creates a new fixed character and a new fixed numeric columns*/
	Select St, TenRegionCode, 'US', Fips, 99
	from lookups.st;
	/*This creates a column based on an arithmetic operator.*/
	Select St, Fips, Fips+1
	from lookups.st;

	/*This concatenates character columns.*/
	/*Note: Concatenation in SAS uses SAS concatenation operators */
	/*      -- in SQL Server Management Studio, we'll use SQL concatenation operators.*/
	Select St, TenRegionCode, ST||'_'||'US', Cat(ST,'_', 'US'), Cats(St,'_', 'US'), Catx('_',ST, 'US')
	from lookups.st;
Quit;
**********************************************************;
/*In the previous step you'll notice that the column heading is blank.*/
/*Calculated columns were assigned a default column name, but SAS displays column labels by default with proc sql.*/
/*When you calculate a column, you need to assign a SQL alias for it. You can also assign a SAS label.*/
/*The code below is the same as the previous step, but with name aliases provided.*/
Proc SQl;
	/*This creates a new fixed character and a new fixed numeric columns*/
	Select St, TenRegionCode, 'US' As Country 'Country', Fips, 99 As CountryFips 'Country Fips'
	from lookups.st;
	/*This creates a column based on an arithmetic operator.*/
	Select St, Fips, Fips+1 As CorrectedFips
	from lookups.st;

	/*This concatenates character columns.*/
	/*Note: Concatenation in SAS uses SAS concatenation operators */
	/*      -- in SQL Server Management Studio, we'll use SQL concatenation operators.*/
	Select 	St, TenRegionCode, 
			ST||'_'||'US' As StateCountryCombo1 'State Country Combo via ||', 
			Cat(ST,'_', 'US') As StateCountryCombo2 'State Country Combo via Cat()', 
			Cats(St,'_', 'US') As StateCountryCombo3 'State Country Combo via Cats()', 
			Catx('_',ST, 'US') As StateCountryCombo4 'State Country Combo via Catx()'
	from lookups.st;
Quit;
