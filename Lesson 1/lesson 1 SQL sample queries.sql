use FarmIncomeInternal

/*A basic SQL query requires 2 clauses: Select and From.*/
/*From tells the query where to get the data.*/
/*Select tells the query which columns you want to see.*/
/*The easiest query is one that returns all the columns using the * in the select clause.*/

	/*This statement selects every column from the st table in the lookups schema, in the FarmIncomeInternal database, in the SQLprod01 server*/
	SELECT *
	FROM lookups.st

	/* use parse (instead of validate) to check the statement for syntax and access privileges*/
	/*Keep in mind this tests syntax, not logic of your query -- it may run, but not neccessarily return what you want.*/
	SELECT *
	FROM lookups.st


		SELT st, TenRegionCode, Fips
	FROM lookups.st

	SELECT st, TenRegionCode, Fips
	FROM lookups.st

	/*You can also create calculated columns within a query.*/
/*Here we run two queries in the same proc sql step. */
/* Each of the two queries creates new column(s) not in the input dataset.*/

	/*This creates a new fixed character and a new fixed numeric columns*/
	Select St, TenRegionCode, 'US', Fips, 99
	from lookups.st
	/*This creates a column based on an arithmetic operator.*/
	Select St, Fips, Fips+1
	from lookups.st

	/*This concatenates character columns.*/
	/*Note: Concatenation in SQL Server Management Studio, we use SQL concatenation operators. SAS uses SAS concatenation operators */
	Select	St, 
			TenRegionCode, 
			ST+'_'+'US', 
			concat(ST,'_', 'US')
	from lookups.st;

	/*This creates a new fixed character and a new fixed numeric columns*/
	Select St, TenRegionCode, 'US' As Country, Fips, 99 As CountryFips
	from lookups.st;
	/*This creates a column based on an arithmetic operator.*/
	Select St, Fips, Fips+1 As CorrectedFips
	from lookups.st;

	/*This concatenates character columns.*/
	/*Note: Concatenation in SAS uses SAS concatenation operators */
	/*      -- in SQL Server Management Studio, we'll use SQL concatenation operators.*/
	Select 	St, TenRegionCode, 
			ST+'_'+'US' As  [State Country Combo via +], 
			Concat(ST,'_', 'US') As [State Country Combo via concat()]
	from lookups.st