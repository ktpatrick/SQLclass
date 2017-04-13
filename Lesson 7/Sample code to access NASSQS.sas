/*Sample code 1*/
/*This code will run without any external DSN file*/
proc sql;
   connect to odbc (required="driver=sql server;Server=sqlprod01;
							  Trusted_Connection=Yes;
							  DATABASE=NASSQUICKSTATS;") ;
    	create table Demo1 as 
    		select * from connection to odbc 
    			( 	SELECT *
	  				FROM [NASSQSFTP].[NASS_QuickStats_Survey]
	  				WHERE Year='2015');
quit; 
 






/*Sample code 2*/
/*This uses an external DSN file to access NASS quickstats data*/

libname NASSQS ODBC NOPROMPT="FILEDSN=Your-DSN-Filepath\NASSQUICKSTATS.dsn;"  	schema=NASSQSFTP;

Proc SQl;
	Create Table Demo2 as
		Select * 
		From NASSQS.NASS_QUICKSTATS_SURVEY
		Where Year='2015';
Quit;