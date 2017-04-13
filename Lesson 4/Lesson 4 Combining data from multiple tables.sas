/*This is the sample MS SQL Server Code for
   Week 4: Combining Data from multiple tables*/

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


/*This starts the section on Set Logic.*/
/*There are four main statements we are going to look at: Union All, Union,
Intersect, and Except.*/
/*General Format for these set logic statements:
SelectStatementOne
(Union All/Union/Intersect/Except)
SelectStatementtwo
Order By columnlist*/
/*The union all operator specifies all rows, even duplicates.*/
Proc Sql;
	select Distinct st 
	from ERSwide.public_data
	Union All
	Select Distinct st 
	from lookups.st
	Order by St;
Quit;
/*This is an example of the union operator.*/
/*The union operator eliminates duplicate rows*/
/*SQL handles data that is in Set A OR Set B.*/
Proc Sql;
	select Distinct st 
	from ERSwide.public_data
	Union 
	Select Distinct st 
	from lookups.st
	Order by St;
Quit;
/*This is an example of using the Union operator with a Where clause.*/
Proc Sql;
	select Distinct st, yyyy, mm, vgroup, vtype 
	from ERSwide.public_data
	where st='AK'

	Union
 
	Select Distinct st 
	from lookups.st
	where st='AK'
	Order by St;
Quit;

/*This is an example of the Intersect operatort.*/
/*SQL handles data that is in Set A AND Set B.*/
Proc Sql;
	select Distinct st, yyyy 
	from Nfarminc.source_data
	where st='AK'
	Intersect
	Select Distinct yyyy 
	from erswide.public_data
	where st='AK'
	Order by st, yyyy;
Quit;

Proc Sql;
	select * 
	from Nfarminc.source_data
	Intersect
	Select * 
	from erswide.public_data
Quit;

/*This is an example of the Except operator.*/
/*SQL handles data that is in Set A, but NOT in Set B.*/
Proc Sql;
	select vtype 
	from ERSwide.public_data
	Except 
	Select vtype
	from Nfarminc.source_data
Quit;
		   
